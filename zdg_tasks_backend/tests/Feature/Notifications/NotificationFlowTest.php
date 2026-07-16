<?php

namespace Tests\Feature\Notifications;

use App\Enums\Role;
use App\Enums\TaskStatus;
use App\Mail\TaskEventMail;
use App\Models\Notification;
use App\Models\Task;
use App\Models\User;
use App\Services\Push\PushSender;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Mail;
use Tests\TestCase;

class FakePushSender implements PushSender
{
    /** @var list<array{tokens: array, title: string, body: string, data: array}> */
    public array $sent = [];

    public function __construct(public bool $configured = true) {}

    public function isConfigured(): bool
    {
        return $this->configured;
    }

    public function send(array $tokens, string $title, string $body, array $data = []): void
    {
        $this->sent[] = compact('tokens', 'title', 'body', 'data');
    }
}

class NotificationFlowTest extends TestCase
{
    use RefreshDatabase;

    private User $deptHead;

    private User $ibsFinance;

    private User $dof;

    private FakePushSender $push;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(DatabaseSeeder::class);
        Mail::fake();

        $this->push = new FakePushSender;
        $this->app->instance(PushSender::class, $this->push);

        $this->deptHead = User::query()->where('role', Role::DeptHead)->sole();
        $this->dof = User::query()->where('role', Role::Dof)->sole();
        $this->ibsFinance = User::factory()
            ->role(Role::CompanyFinance)
            ->inCompany($this->deptHead->company)
            ->create();
    }

    /** @return array<int, string> */
    private function eventsFor(User $user): array
    {
        return Notification::query()
            ->where('user_id', $user->id)
            ->orderBy('id')
            ->pluck('event')
            ->all();
    }

    private function submittedTask(): Task
    {
        $response = $this->actingAs($this->deptHead, 'sanctum')->postJson('/api/tasks', [
            'title' => 'Notification test request',
            'description' => 'Testing notification wiring.',
            'amount_requested' => 100000,
            'due_date' => now()->addWeek()->toDateString(),
            'beneficiary_type' => 'self',
        ]);
        $task = Task::query()->findOrFail($response->json('task.id'));
        $this->actingAs($this->deptHead, 'sanctum')->postJson("/api/tasks/{$task->id}/submit")->assertOk();

        return $task->refresh();
    }

    public function test_submission_notifies_the_company_finance_office_only(): void
    {
        $zdcFinance = User::query()
            ->where('role', Role::CompanyFinance)
            ->where('company_id', '!=', $this->deptHead->company_id)
            ->sole();

        $this->submittedTask();

        $this->assertSame(['submission_received'], $this->eventsFor($this->ibsFinance));
        // Chain-end rule: the requester is not notified of their own
        // submission; other offices and the dof are not addressed.
        $this->assertSame([], $this->eventsFor($this->deptHead));
        $this->assertSame([], $this->eventsFor($zdcFinance));
        $this->assertSame([], $this->eventsFor($this->dof));

        Mail::assertSent(TaskEventMail::class, fn (TaskEventMail $mail) => $mail->hasTo($this->ibsFinance->email));
    }

    public function test_plain_approval_notifies_the_requester_once(): void
    {
        $task = $this->submittedTask();

        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/approve", ['receipt_required' => false])
            ->assertOk();

        $this->assertSame(['approved'], $this->eventsFor($this->deptHead));
    }

    public function test_edited_approval_with_receipt_fires_each_event(): void
    {
        $task = $this->submittedTask();

        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/approve", [
                'amount_approved' => 80000,
                'amount_edit_reason' => 'Trimmed to the framework rate.',
                'receipt_required' => true,
            ])
            ->assertOk();

        $this->assertSame(
            ['approved', 'amount_edited', 'receipt_requested'],
            $this->eventsFor($this->deptHead),
        );
    }

    public function test_assignment_notifies_the_assigned_funder(): void
    {
        $task = $this->submittedTask();

        $this->actingAs($this->dof, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/approve", [
                'receipt_required' => false,
                'assigned_funder_id' => $this->ibsFinance->id,
            ])
            ->assertOk();

        $this->assertContains('assigned', $this->eventsFor($this->ibsFinance));
    }

    public function test_rejection_and_postponement_notify_the_requester(): void
    {
        $task = $this->submittedTask();

        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/postpone", [
                'due_date' => now()->addWeeks(2)->toDateString(),
                'reason' => 'Cash flow timing.',
            ])
            ->assertOk();

        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/reject", ['reason' => 'Not budgeted.'])
            ->assertOk();

        $this->assertSame(['postponed', 'rejected'], $this->eventsFor($this->deptHead));
    }

    public function test_petty_cash_issue_and_close_notify_the_recipient(): void
    {
        $create = $this->actingAs($this->ibsFinance, 'sanctum')->postJson('/api/petty-cash', [
            'recipient_id' => $this->deptHead->id,
            'amount_issued' => 50000,
            'purpose' => 'Notification check.',
        ])->assertCreated();

        $taskId = $create->json('task.id');
        $this->assertSame(['receipt_requested'], $this->eventsFor($this->deptHead));

        // Fully reconcile with a returned balance, then close.
        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$taskId}/return-balance", ['amount' => 50000])
            ->assertOk();
        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$taskId}/close")
            ->assertOk();

        $this->assertSame(['receipt_requested', 'completed'], $this->eventsFor($this->deptHead));
    }

    public function test_uploading_your_own_receipt_does_not_self_notify(): void
    {
        $task = $this->submittedTask();
        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/approve", ['receipt_required' => true])
            ->assertOk();

        Notification::query()->delete();

        $this->actingAs($this->deptHead, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/receipts", [
                'file' => UploadedFile::fake()->create('proof.pdf', 50, 'application/pdf'),
                'amount' => 100000,
            ])
            ->assertCreated();

        $this->assertSame([], $this->eventsFor($this->deptHead));
    }

    public function test_escalation_notifies_the_dof_and_never_the_requester(): void
    {
        $task = Task::factory()->createdBy($this->deptHead)->create([
            'status' => TaskStatus::PendingApproval,
            'due_date' => now()->subDays(20)->toDateString(),
        ]);

        $this->artisan('tasks:escalate')->assertSuccessful();

        $this->assertSame(TaskStatus::Escalated, $task->refresh()->status);
        $this->assertSame(['escalated'], $this->eventsFor($this->dof));
        $this->assertSame([], $this->eventsFor($this->deptHead));
    }

    public function test_technical_actions_notify_nobody(): void
    {
        $technical = User::query()->where('role', Role::Technical)->sole();
        $task = $this->submittedTask();

        Notification::query()->delete();

        $this->actingAs($technical, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/approve", ['receipt_required' => false])
            ->assertOk();

        $this->assertSame(0, Notification::query()->count());
    }

    public function test_push_channel_requires_a_device_token_and_configured_sender(): void
    {
        // Without a token: no push channel recorded.
        $task = $this->submittedTask();
        $record = Notification::query()->where('user_id', $this->ibsFinance->id)->sole();
        $this->assertSame(['in_app', 'email'], $record->channels_sent);
        $this->assertSame([], $this->push->sent);

        // Register a device token for the finance user; the next event
        // reaches all three channels.
        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson('/api/device-tokens', ['token' => 'fcm-token-123', 'platform' => 'android'])
            ->assertCreated();

        Notification::query()->delete();
        $this->submittedTask();

        $record = Notification::query()->where('user_id', $this->ibsFinance->id)->sole();
        $this->assertSame(['in_app', 'email', 'push'], $record->channels_sent);
        $this->assertCount(1, $this->push->sent);
        $this->assertSame(['fcm-token-123'], $this->push->sent[0]['tokens']);
    }

    public function test_unconfigured_push_sender_downgrades_gracefully(): void
    {
        $this->push->configured = false;
        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson('/api/device-tokens', ['token' => 'fcm-token-456'])
            ->assertCreated();

        $this->submittedTask();

        $record = Notification::query()->where('user_id', $this->ibsFinance->id)->sole();
        $this->assertSame(['in_app', 'email'], $record->channels_sent);
        $this->assertSame([], $this->push->sent);
    }

    public function test_notification_endpoints_list_own_and_mark_read(): void
    {
        $this->submittedTask();
        $record = Notification::query()->where('user_id', $this->ibsFinance->id)->sole();

        // The owner lists and reads their notification.
        $this->actingAs($this->ibsFinance, 'sanctum')
            ->getJson('/api/notifications?unread=1')
            ->assertOk()
            ->assertJsonPath('data.0.event', 'submission_received');

        $this->actingAs($this->ibsFinance, 'sanctum')
            ->patchJson("/api/notifications/{$record->id}/read")
            ->assertOk();
        $this->assertNotNull($record->refresh()->read_at);

        // Someone else's notification is untouchable and unlisted.
        $this->actingAs($this->deptHead, 'sanctum')
            ->patchJson("/api/notifications/{$record->id}/read")
            ->assertForbidden();
        $this->actingAs($this->deptHead, 'sanctum')
            ->getJson('/api/notifications')
            ->assertOk()
            ->assertJsonMissing(['id' => $record->id]);
    }
}
