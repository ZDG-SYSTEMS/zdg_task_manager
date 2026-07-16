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

class ApprovalEngineTest extends TestCase
{
    use RefreshDatabase;

    private User $deptHead;

    private User $dof;

    private User $ibsFinance;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(DatabaseSeeder::class);
        Storage::fake();

        $this->deptHead = User::query()->where('role', Role::DeptHead)->sole();
        $this->dof = User::query()->where('role', Role::Dof)->sole();
        // A finance user in the dept head's company (IBS) so approvals
        // happen in the right office.
        $this->ibsFinance = User::factory()
            ->role(Role::CompanyFinance)
            ->inCompany($this->deptHead->company)
            ->create();
    }

    private function pendingTask(): Task
    {
        return Task::factory()->createdBy($this->deptHead)->create([
            'status' => TaskStatus::PendingApproval,
            'amount_requested' => 500000,
        ]);
    }

    /** @return list<array{0: ?string, 1: string}> */
    private function trail(Task $task): array
    {
        return $task->auditEntries()
            ->orderBy('id')
            ->get()
            ->map(fn ($entry) => [$entry->from_state?->value, $entry->to_state->value])
            ->all();
    }

    public function test_approve_without_receipt_completes_and_defaults_amount(): void
    {
        $task = $this->pendingTask();

        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/approve", ['receipt_required' => false])
            ->assertOk()
            ->assertJsonPath('task.status', 'completed');

        $task->refresh();
        $this->assertSame(500000, $task->amount_approved);
        $this->assertNull($task->amount_edit_reason);
        $this->assertFalse($task->receipt_required);

        $this->assertSame([
            ['pending_approval', 'approved'],
            ['approved', 'completed'],
        ], $this->trail($task));
    }

    public function test_approve_with_receipt_required_waits_for_proof(): void
    {
        $task = $this->pendingTask();

        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/approve", ['receipt_required' => true])
            ->assertOk()
            ->assertJsonPath('task.status', 'pending_receipt');

        // The creator uploads proof of purchase; the task completes.
        $this->actingAs($this->deptHead, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/receipts", [
                'file' => UploadedFile::fake()->create('proof.pdf', 100, 'application/pdf'),
                'amount' => 500000,
            ])
            ->assertCreated()
            ->assertJsonPath('task.status', 'completed');

        $task->refresh();
        $this->assertSame(1, $task->receipts()->count());
        $this->assertSame([
            ['pending_approval', 'approved'],
            ['approved', 'pending_receipt'],
            ['pending_receipt', 'completed'],
        ], $this->trail($task));
    }

    public function test_amount_edit_requires_a_reason(): void
    {
        $task = $this->pendingTask();

        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/approve", [
                'amount_approved' => 400000,
                'receipt_required' => false,
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors('amount_edit_reason');

        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/approve", [
                'amount_approved' => 400000,
                'amount_edit_reason' => 'Quoted price was above the framework rate.',
                'receipt_required' => false,
            ])
            ->assertOk();

        $task->refresh();
        $this->assertSame(400000, $task->amount_approved);
        $this->assertSame('Quoted price was above the framework rate.', $task->amount_edit_reason);

        // The audit entry for the approval carries the edit reason.
        $approvalEntry = $task->auditEntries()
            ->where('to_state', TaskStatus::Approved)
            ->sole();
        $this->assertSame('Quoted price was above the framework rate.', $approvalEntry->reason);
    }

    public function test_approve_and_assign_is_dof_only_and_validates_the_funder(): void
    {
        $task = $this->pendingTask();

        // company_finance cannot assign.
        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/approve", [
                'receipt_required' => false,
                'assigned_funder_id' => $this->ibsFinance->id,
            ])
            ->assertForbidden();

        // dof cannot assign someone outside the task's company.
        $zdcFinance = User::query()->where('role', Role::CompanyFinance)
            ->where('company_id', '!=', $task->company_id)->first();
        $this->actingAs($this->dof, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/approve", [
                'receipt_required' => false,
                'assigned_funder_id' => $zdcFinance->id,
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors('assigned_funder_id');

        // dof cannot assign a non-finance user.
        $this->actingAs($this->dof, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/approve", [
                'receipt_required' => false,
                'assigned_funder_id' => $this->deptHead->id,
            ])
            ->assertUnprocessable();

        // dof assigns the task company's finance user.
        $this->actingAs($this->dof, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/approve", [
                'receipt_required' => false,
                'assigned_funder_id' => $this->ibsFinance->id,
            ])
            ->assertOk();

        $this->assertSame($this->ibsFinance->id, $task->refresh()->assigned_funder_id);
    }

    public function test_assignable_funders_are_scoped_to_the_dof(): void
    {
        $task = $this->pendingTask();

        // Only the dof (and flagged technical) may enumerate funders.
        $this->actingAs($this->ibsFinance, 'sanctum')
            ->getJson("/api/tasks/{$task->id}/assignable-funders")
            ->assertForbidden();

        $response = $this->actingAs($this->dof, 'sanctum')
            ->getJson("/api/tasks/{$task->id}/assignable-funders")
            ->assertOk();

        // Only the task company's finance users are listed.
        $ids = array_column($response->json('funders'), 'id');
        $this->assertContains($this->ibsFinance->id, $ids);
        $zdcFinance = User::query()->where('role', Role::CompanyFinance)
            ->where('company_id', '!=', $task->company_id)->first();
        $this->assertNotContains($zdcFinance->id, $ids);
    }

    public function test_reject_requires_reason_and_allows_edit_and_resubmit(): void
    {
        $task = $this->pendingTask();

        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/reject", [])
            ->assertUnprocessable()
            ->assertJsonValidationErrors('reason');

        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/reject", ['reason' => 'No supporting quotation.'])
            ->assertOk()
            ->assertJsonPath('task.status', 'rejected');

        // The requester edits the rejected request.
        $this->actingAs($this->deptHead, 'sanctum')
            ->patchJson("/api/tasks/{$task->id}", ['description' => 'Now with quotation attached.'])
            ->assertOk();

        // And resubmits it to the approval queue.
        $this->actingAs($this->deptHead, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/resubmit")
            ->assertOk()
            ->assertJsonPath('task.status', 'pending_approval');

        $this->assertSame([
            ['pending_approval', 'rejected'],
            ['rejected', 'pending_approval'],
        ], array_slice($this->trail($task->refresh()), -2));
    }

    public function test_only_the_requester_resubmits(): void
    {
        $task = Task::factory()->createdBy($this->deptHead)->create([
            'status' => TaskStatus::Rejected,
        ]);

        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/resubmit")
            ->assertForbidden();
    }

    public function test_postpone_passes_through_the_postponed_state(): void
    {
        $task = $this->pendingTask();
        $newDate = now()->addWeeks(2)->toDateString();

        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/postpone", [
                'due_date' => $newDate,
                'reason' => 'Funds unavailable until month end.',
            ])
            ->assertOk()
            ->assertJsonPath('task.status', 'pending_approval');

        $task->refresh();
        $this->assertSame($newDate, $task->due_date->toDateString());
        $this->assertSame([
            ['pending_approval', 'postponed'],
            ['postponed', 'pending_approval'],
        ], array_slice($this->trail($task), -2));

        // The approver may later edit the postponed date.
        $laterDate = now()->addWeeks(4)->toDateString();
        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/postpone", [
                'due_date' => $laterDate,
                'reason' => 'Board meeting moved.',
            ])
            ->assertOk();
        $this->assertSame($laterDate, $task->refresh()->due_date->toDateString());
    }

    public function test_funding_is_recorded_after_approval_with_its_own_audit_entry(): void
    {
        $task = $this->pendingTask();

        // Cannot fund an unapproved task.
        $this->actingAs($this->dof, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/fund", [
                'funded_amount' => 500000,
                'funded_reference' => 'CHQ-0001',
            ])
            ->assertUnprocessable();

        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/approve", ['receipt_required' => true])
            ->assertOk();

        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/fund", [
                'funded_amount' => 480000,
                'funded_reference' => 'CHQ-0001',
            ])
            ->assertOk()
            ->assertJsonPath('task.funded', true);

        $task->refresh();
        $this->assertSame(480000, $task->funded_amount);
        $this->assertSame('CHQ-0001', $task->funded_reference);
        $this->assertSame($this->ibsFinance->id, $task->funded_by);
        $this->assertNotNull($task->funded_at);
        // Funding is an overlay: state unchanged, audited as its own
        // entry with from = to.
        $this->assertSame(TaskStatus::PendingReceipt, $task->status);
        $fundingEntry = $task->auditEntries()->orderByDesc('id')->first();
        $this->assertSame(TaskStatus::PendingReceipt, $fundingEntry->from_state);
        $this->assertSame(TaskStatus::PendingReceipt, $fundingEntry->to_state);
        $this->assertStringContainsString('CHQ-0001', $fundingEntry->reason);

        // Funding never blocks completion: proof still completes it.
        $this->actingAs($this->deptHead, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/receipts", [
                'file' => UploadedFile::fake()->create('proof.pdf', 100, 'application/pdf'),
                'amount' => 480000,
            ])
            ->assertCreated()
            ->assertJsonPath('task.status', 'completed');

        // A second funding record is refused.
        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/fund", [
                'funded_amount' => 480000,
                'funded_reference' => 'CHQ-0002',
            ])
            ->assertUnprocessable();
    }

    public function test_non_approvers_are_denied_every_approval_action(): void
    {
        $task = $this->pendingTask();

        // Valid payloads so the requests reach the authorization layer.
        $payloads = [
            'approve' => ['receipt_required' => false],
            'reject' => ['reason' => 'Denied attempt.'],
            'postpone' => ['due_date' => now()->addWeek()->toDateString(), 'reason' => 'Denied attempt.'],
            'fund' => ['funded_amount' => 1000, 'funded_reference' => 'CHQ-X'],
        ];

        foreach ($payloads as $action => $payload) {
            $this->actingAs($this->deptHead, 'sanctum')
                ->postJson("/api/tasks/{$task->id}/{$action}", $payload)
                ->assertForbidden();
        }
    }

    public function test_technical_approval_is_tamper_flagged_and_requeued(): void
    {
        $technical = User::query()->where('role', Role::Technical)->sole();
        $task = $this->pendingTask();

        $this->actingAs($technical, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/approve", ['receipt_required' => false])
            ->assertOk()
            ->assertJsonPath('task.status', 'pending_approval');

        $task->refresh();
        $this->assertTrue($task->via_technical);
        $this->assertSame([
            ['pending_approval', 'approved'],
            ['approved', 'pending_approval'],
        ], array_slice($this->trail($task), -2));

        $this->assertTrue(
            $task->auditEntries()
                ->whereIn('to_state', [TaskStatus::Approved, TaskStatus::PendingApproval])
                ->get()
                ->every(fn ($entry) => $entry->via_technical),
        );
    }

    public function test_technical_rejection_is_requeued_too(): void
    {
        $technical = User::query()->where('role', Role::Technical)->sole();
        $task = $this->pendingTask();

        $this->actingAs($technical, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/reject", ['reason' => 'Exercising the reject path.'])
            ->assertOk()
            ->assertJsonPath('task.status', 'pending_approval');

        $this->assertSame([
            ['pending_approval', 'rejected'],
            ['rejected', 'pending_approval'],
        ], array_slice($this->trail($task->refresh()), -2));
    }

    public function test_receipt_upload_is_refused_when_not_awaiting_proof(): void
    {
        $task = $this->pendingTask();

        $this->actingAs($this->deptHead, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/receipts", [
                'file' => UploadedFile::fake()->create('early.pdf', 100, 'application/pdf'),
                'amount' => 100000,
            ])
            ->assertUnprocessable();
    }
}
