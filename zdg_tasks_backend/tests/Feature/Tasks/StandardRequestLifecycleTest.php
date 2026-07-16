<?php

namespace Tests\Feature\Tasks;

use App\Enums\Role;
use App\Enums\TaskStatus;
use App\Models\Company;
use App\Models\Task;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class StandardRequestLifecycleTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(DatabaseSeeder::class);
    }

    private function actor(Role $role): User
    {
        return User::query()->where('role', $role)->sole();
    }

    /**
     * @param  array<string, mixed>  $overrides
     * @return array<string, mixed>
     */
    private function completePayload(array $overrides = []): array
    {
        return [
            'title' => 'Office chairs',
            'description' => 'Replacement chairs for the operations office.',
            'amount_requested' => 250000,
            'due_date' => now()->addWeek()->toDateString(),
            'beneficiary_type' => 'self',
            ...$overrides,
        ];
    }

    public function test_create_draft_writes_audit_and_attaches_creator(): void
    {
        $deptHead = $this->actor(Role::DeptHead);

        $response = $this->actingAs($deptHead, 'sanctum')
            ->postJson('/api/tasks', ['title' => 'Office chairs'])
            ->assertCreated();

        $response->assertJsonPath('task.status', 'draft');
        // Creator name and position auto-attach and display.
        $response->assertJsonPath('task.creator.name', $deptHead->name);
        $response->assertJsonPath('task.creator.position', $deptHead->position);
        $response->assertJsonPath('task.company.code', $deptHead->company->code);

        $task = Task::query()->findOrFail($response->json('task.id'));
        $this->assertFalse($task->via_technical);

        $entry = $task->auditEntries()->sole();
        $this->assertNull($entry->from_state);
        $this->assertSame(TaskStatus::Draft, $entry->to_state);
        $this->assertFalse($entry->via_technical);
    }

    public function test_draft_requires_a_title(): void
    {
        $this->actingAs($this->actor(Role::DeptHead), 'sanctum')
            ->postJson('/api/tasks', ['description' => 'No title given'])
            ->assertUnprocessable()
            ->assertJsonValidationErrors('title');
    }

    public function test_description_over_150_words_is_rejected_at_input(): void
    {
        $this->actingAs($this->actor(Role::DeptHead), 'sanctum')
            ->postJson('/api/tasks', [
                'title' => 'Wordy request',
                'description' => trim(str_repeat('word ', 151)),
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors('description');
    }

    public function test_only_the_creator_edits_their_draft(): void
    {
        $deptHead = $this->actor(Role::DeptHead);
        $task = Task::factory()->createdBy($deptHead)->create(['status' => TaskStatus::Draft]);

        $this->actingAs($deptHead, 'sanctum')
            ->patchJson("/api/tasks/{$task->id}", ['title' => 'Renamed request'])
            ->assertOk();
        $this->assertSame('Renamed request', $task->refresh()->title);

        $this->actingAs($this->actor(Role::Director), 'sanctum')
            ->patchJson("/api/tasks/{$task->id}", ['title' => 'Hijacked'])
            ->assertForbidden();
    }

    public function test_submitted_task_is_no_longer_editable(): void
    {
        $deptHead = $this->actor(Role::DeptHead);
        $task = Task::factory()->createdBy($deptHead)->create([
            'status' => TaskStatus::PendingApproval,
        ]);

        $this->actingAs($deptHead, 'sanctum')
            ->patchJson("/api/tasks/{$task->id}", ['title' => 'Too late'])
            ->assertForbidden();
    }

    public function test_incomplete_draft_cannot_submit_and_stays_draft(): void
    {
        $deptHead = $this->actor(Role::DeptHead);

        $create = $this->actingAs($deptHead, 'sanctum')
            ->postJson('/api/tasks', ['title' => 'Bare draft'])
            ->assertCreated();

        $taskId = $create->json('task.id');

        $this->actingAs($deptHead, 'sanctum')
            ->postJson("/api/tasks/{$taskId}/submit")
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'description', 'amount_requested', 'due_date', 'beneficiary_type',
            ]);

        $task = Task::query()->findOrFail($taskId);
        $this->assertSame(TaskStatus::Draft, $task->status);
        // Only the creation entry exists; no transition was recorded.
        $this->assertSame(1, $task->auditEntries()->count());
    }

    public function test_beneficiary_other_requires_a_name_on_submit(): void
    {
        $deptHead = $this->actor(Role::DeptHead);

        $create = $this->actingAs($deptHead, 'sanctum')
            ->postJson('/api/tasks', $this->completePayload([
                'beneficiary_type' => 'other',
                'beneficiary_name' => null,
            ]));

        $create->assertUnprocessable()->assertJsonValidationErrors('beneficiary_name');
    }

    public function test_complete_draft_submits_and_routes_to_pending_approval(): void
    {
        $deptHead = $this->actor(Role::DeptHead);

        $create = $this->actingAs($deptHead, 'sanctum')
            ->postJson('/api/tasks', $this->completePayload())
            ->assertCreated();

        $taskId = $create->json('task.id');

        $this->actingAs($deptHead, 'sanctum')
            ->postJson("/api/tasks/{$taskId}/submit")
            ->assertOk()
            ->assertJsonPath('task.status', 'pending_approval');

        $task = Task::query()->findOrFail($taskId);

        $trail = $task->auditEntries()
            ->orderBy('id')
            ->get()
            ->map(fn ($entry) => [$entry->from_state?->value, $entry->to_state->value])
            ->all();

        $this->assertSame([
            [null, 'draft'],
            ['draft', 'submitted'],
            ['submitted', 'pending_approval'],
        ], $trail);

        $this->assertFalse($task->via_technical);
    }

    public function test_submitted_request_reaches_the_right_queues(): void
    {
        $deptHead = $this->actor(Role::DeptHead);
        $ibs = $deptHead->company;
        // Resolve the seeded ZDC finance user before adding a second
        // company_finance account for IBS.
        $zdcFinance = $this->actor(Role::CompanyFinance);

        $create = $this->actingAs($deptHead, 'sanctum')
            ->postJson('/api/tasks', $this->completePayload());
        $taskId = $create->json('task.id');
        $this->actingAs($deptHead, 'sanctum')->postJson("/api/tasks/{$taskId}/submit")->assertOk();

        // Own-company finance sees it in the approval queue.
        $ibsFinance = User::factory()->role(Role::CompanyFinance)->inCompany($ibs)->create();
        $this->actingAs($ibsFinance, 'sanctum')
            ->getJson('/api/tasks?status=pending_approval')
            ->assertOk()
            ->assertJsonPath('data.0.id', $taskId);

        // The dof sees it cross-company.
        $this->actingAs($this->actor(Role::Dof), 'sanctum')
            ->getJson('/api/tasks?status=pending_approval')
            ->assertOk()
            ->assertJsonFragment(['id' => $taskId]);

        // Finance of another company does not.
        $this->actingAs($zdcFinance, 'sanctum')
            ->getJson('/api/tasks?status=pending_approval')
            ->assertOk()
            ->assertJsonMissing(['id' => $taskId]);
    }

    public function test_technical_actions_are_tamper_flagged(): void
    {
        $technical = $this->actor(Role::Technical);

        $create = $this->actingAs($technical, 'sanctum')
            ->postJson('/api/tasks', $this->completePayload())
            ->assertCreated();

        $taskId = $create->json('task.id');
        $task = Task::query()->findOrFail($taskId);
        $this->assertTrue($task->via_technical);

        $this->actingAs($technical, 'sanctum')
            ->postJson("/api/tasks/{$taskId}/submit")
            ->assertOk();

        $this->assertTrue(
            $task->auditEntries()->get()->every(fn ($entry) => $entry->via_technical)
        );
    }

    public function test_illegal_transition_is_rejected_with_conflict(): void
    {
        $deptHead = $this->actor(Role::DeptHead);

        $create = $this->actingAs($deptHead, 'sanctum')
            ->postJson('/api/tasks', $this->completePayload());
        $taskId = $create->json('task.id');

        $this->actingAs($deptHead, 'sanctum')->postJson("/api/tasks/{$taskId}/submit")->assertOk();

        // Submitting again: the task is pending_approval, no longer a
        // draft the creator may act on.
        $this->actingAs($deptHead, 'sanctum')
            ->postJson("/api/tasks/{$taskId}/submit")
            ->assertForbidden();
    }

    public function test_auto_draft_reason_is_recorded(): void
    {
        $deptHead = $this->actor(Role::DeptHead);

        $response = $this->actingAs($deptHead, 'sanctum')
            ->postJson('/api/tasks', [
                'title' => 'Recovered request',
                'draft_reason' => 'Network failure during submission',
            ])
            ->assertCreated();

        $this->assertSame(
            'Network failure during submission',
            Task::query()->findOrFail($response->json('task.id'))->draft_reason,
        );
    }

    public function test_priority_is_hidden_from_non_approvers(): void
    {
        $deptHead = $this->actor(Role::DeptHead);
        $task = Task::factory()->createdBy($deptHead)->create([
            'status' => TaskStatus::PendingApproval,
            'priority' => 'high',
        ]);

        $this->actingAs($deptHead, 'sanctum')
            ->getJson("/api/tasks/{$task->id}")
            ->assertOk()
            ->assertJsonMissingPath('task.priority');

        $ibsFinance = User::factory()->role(Role::CompanyFinance)->inCompany($deptHead->company)->create();
        $this->actingAs($ibsFinance, 'sanctum')
            ->getJson("/api/tasks/{$task->id}")
            ->assertOk()
            ->assertJsonPath('task.priority', 'high');
    }
}
