<?php

namespace Tests\Feature\Tasks;

use App\Enums\Role;
use App\Enums\TaskStatus;
use App\Models\Task;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class PettyCashFlowTest extends TestCase
{
    use RefreshDatabase;

    private User $deptHead;

    private User $ibsFinance;

    private User $dof;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(DatabaseSeeder::class);
        Storage::fake();

        $this->deptHead = User::query()->where('role', Role::DeptHead)->sole();
        $this->dof = User::query()->where('role', Role::Dof)->sole();
        // Finance in the recipient's company (IBS).
        $this->ibsFinance = User::factory()
            ->role(Role::CompanyFinance)
            ->inCompany($this->deptHead->company)
            ->create();
    }

    /** @param array<string, mixed> $overrides */
    private function issue(User $actor, array $overrides = []): Task
    {
        $response = $this->actingAs($actor, 'sanctum')->postJson('/api/petty-cash', [
            'recipient_id' => $this->deptHead->id,
            'amount_issued' => 100000,
            'purpose' => 'Field trip incidentals.',
            ...$overrides,
        ]);
        $response->assertCreated();

        return Task::query()->findOrFail($response->json('task.id'));
    }

    private function uploadReceipt(Task $task, int $amount): int
    {
        $response = $this->actingAs($this->deptHead, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/receipts", [
                'file' => UploadedFile::fake()->create('receipt.pdf', 50, 'application/pdf'),
                'amount' => $amount,
            ]);
        $response->assertCreated();

        return $response->json('receipt.id');
    }

    public function test_finance_issues_petty_cash_immediately_with_audit(): void
    {
        $task = $this->issue($this->ibsFinance, ['receipt_due_date' => now()->addMonth()->toDateString()]);

        $this->assertSame(TaskStatus::PendingReceipt, $task->status);
        $this->assertSame('petty_cash', $task->type->value);
        $this->assertSame(100000, $task->amount_issued);
        $this->assertSame(0, $task->amount_accounted);
        $this->assertSame($this->deptHead->id, $task->recipient_id);
        $this->assertSame($this->deptHead->company_id, $task->company_id);
        $this->assertSame('Petty cash - '.$this->deptHead->name, $task->title);

        // Issued immediately: a single creation audit entry, no approval.
        $entry = $task->auditEntries()->sole();
        $this->assertNull($entry->from_state);
        $this->assertSame(TaskStatus::PendingReceipt, $entry->to_state);
    }

    public function test_dof_issues_cross_company_but_finance_cannot(): void
    {
        // dof issues for an IBS recipient without restriction.
        $task = $this->issue($this->dof);
        $this->assertSame($this->deptHead->company_id, $task->company_id);

        // ZDC finance cannot issue to an IBS recipient.
        $zdcFinance = User::query()
            ->where('role', Role::CompanyFinance)
            ->where('company_id', '!=', $this->deptHead->company_id)
            ->first();

        $this->actingAs($zdcFinance, 'sanctum')->postJson('/api/petty-cash', [
            'recipient_id' => $this->deptHead->id,
            'amount_issued' => 50000,
            'purpose' => 'Cross-company attempt.',
        ])->assertUnprocessable()->assertJsonValidationErrors('recipient_id');
    }

    public function test_non_finance_roles_cannot_create_petty_cash(): void
    {
        foreach ([Role::Director, Role::DeptHead, Role::Auditor] as $role) {
            $actor = User::query()->where('role', $role)->sole();

            $this->actingAs($actor, 'sanctum')->postJson('/api/petty-cash', [
                'recipient_id' => $this->deptHead->id,
                'amount_issued' => 50000,
                'purpose' => 'Should be blocked.',
            ])->assertForbidden();
        }
    }

    public function test_recipient_views_task_and_uploads_receipts_over_time(): void
    {
        $task = $this->issue($this->ibsFinance);

        $this->actingAs($this->deptHead, 'sanctum')
            ->getJson("/api/tasks/{$task->id}")
            ->assertOk()
            ->assertJsonPath('task.amount_issued', 100000)
            ->assertJsonPath('task.balance_remaining', 100000);

        $this->uploadReceipt($task, 30000);
        $this->uploadReceipt($task, 45000);

        // Unverified receipts do not count toward the accounted figure.
        $task->refresh();
        $this->assertSame(0, $task->amount_accounted);
        $this->assertSame(2, $task->receipts()->count());
        $this->assertSame(TaskStatus::PendingReceipt, $task->status);
    }

    public function test_partial_reconciliation_cannot_close(): void
    {
        $task = $this->issue($this->ibsFinance);
        $receiptId = $this->uploadReceipt($task, 30000);

        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/receipts/{$receiptId}/verify")
            ->assertOk()
            ->assertJsonPath('task.amount_accounted', 30000)
            ->assertJsonPath('task.balance_remaining', 70000);

        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/close")
            ->assertUnprocessable();

        $this->assertSame(TaskStatus::PendingReceipt, $task->refresh()->status);
    }

    public function test_full_reconciliation_with_returned_balance_closes(): void
    {
        $task = $this->issue($this->ibsFinance);

        $first = $this->uploadReceipt($task, 30000);
        $second = $this->uploadReceipt($task, 45000);

        foreach ([$first, $second] as $receiptId) {
            $this->actingAs($this->ibsFinance, 'sanctum')
                ->postJson("/api/tasks/{$task->id}/receipts/{$receiptId}/verify")
                ->assertOk();
        }

        $task->refresh();
        $this->assertSame(75000, $task->amount_accounted);

        // The recipient hands back the remaining 25000 in cash.
        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/return-balance", ['amount' => 25000])
            ->assertOk()
            ->assertJsonPath('task.balance_remaining', 0);

        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/close")
            ->assertOk()
            ->assertJsonPath('task.status', 'completed');

        // The closing transition is audited with the reconciliation.
        $closing = $task->auditEntries()->orderByDesc('id')->first();
        $this->assertSame(TaskStatus::PendingReceipt, $closing->from_state);
        $this->assertSame(TaskStatus::Completed, $closing->to_state);
        $this->assertStringContainsString('75000', $closing->reason);
        $this->assertStringContainsString('25000', $closing->reason);
    }

    public function test_exact_spend_closes_without_returned_balance(): void
    {
        $task = $this->issue($this->ibsFinance);
        $receiptId = $this->uploadReceipt($task, 100000);

        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/receipts/{$receiptId}/verify")
            ->assertOk();

        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/close")
            ->assertOk()
            ->assertJsonPath('task.status', 'completed');
    }

    public function test_double_verification_is_refused(): void
    {
        $task = $this->issue($this->ibsFinance);
        $receiptId = $this->uploadReceipt($task, 30000);

        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/receipts/{$receiptId}/verify")
            ->assertOk();

        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/receipts/{$receiptId}/verify")
            ->assertUnprocessable();
    }

    public function test_recipient_cannot_verify_return_or_close(): void
    {
        $task = $this->issue($this->ibsFinance);
        $receiptId = $this->uploadReceipt($task, 100000);

        $this->actingAs($this->deptHead, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/receipts/{$receiptId}/verify")
            ->assertForbidden();

        $this->actingAs($this->deptHead, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/return-balance", ['amount' => 0])
            ->assertForbidden();

        $this->actingAs($this->deptHead, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/close")
            ->assertForbidden();
    }

    public function test_uploads_are_locked_after_close(): void
    {
        $task = $this->issue($this->ibsFinance);
        $receiptId = $this->uploadReceipt($task, 100000);

        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/receipts/{$receiptId}/verify")
            ->assertOk();
        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/close")
            ->assertOk();

        $this->actingAs($this->deptHead, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/receipts", [
                'file' => UploadedFile::fake()->create('late.pdf', 50, 'application/pdf'),
                'amount' => 1000,
            ])
            ->assertUnprocessable();
    }

    public function test_technical_verification_and_close_have_no_effect_but_are_flagged(): void
    {
        $technical = User::query()->where('role', Role::Technical)->sole();
        $task = $this->issue($this->ibsFinance);
        $receiptId = $this->uploadReceipt($task, 100000);

        // Technical exercises verify: the receipt stays unverified.
        $this->actingAs($technical, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/receipts/{$receiptId}/verify")
            ->assertOk();

        $task->refresh();
        $this->assertFalse($task->receipts()->sole()->verified);
        $this->assertSame(0, $task->amount_accounted);

        // Technical exercises close: the task stays open.
        $this->actingAs($technical, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/close")
            ->assertOk();
        $this->assertSame(TaskStatus::PendingReceipt, $task->refresh()->status);

        // Both attempts are tamper-flagged in the audit trail.
        $flagged = $task->auditEntries()->where('via_technical', true)->get();
        $this->assertCount(2, $flagged);
        $this->assertTrue(
            $flagged->every(fn ($entry) => $entry->from_state === $entry->to_state),
        );
    }
}
