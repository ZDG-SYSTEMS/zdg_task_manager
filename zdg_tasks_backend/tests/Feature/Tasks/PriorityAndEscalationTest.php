<?php

namespace Tests\Feature\Tasks;

use App\Enums\Priority;
use App\Enums\Role;
use App\Enums\TaskStatus;
use App\Models\Task;
use App\Models\User;
use App\Services\EscalationService;
use App\Services\PriorityService;
use Carbon\CarbonImmutable;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Tests\TestCase;

class PriorityAndEscalationTest extends TestCase
{
    use RefreshDatabase;

    private User $deptHead;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(DatabaseSeeder::class);
        $this->deptHead = User::query()->where('role', Role::DeptHead)->sole();
    }

    protected function tearDown(): void
    {
        Carbon::setTestNow();
        parent::tearDown();
    }

    private function pendingTask(array $overrides = []): Task
    {
        return Task::factory()->createdBy($this->deptHead)->create([
            'status' => TaskStatus::PendingApproval,
            'due_date' => now()->addMonth()->toDateString(),
            ...$overrides,
        ]);
    }

    public function test_priority_bands_follow_the_weekday(): void
    {
        // 2026-07-20 is a Monday.
        $expectations = [
            '2026-07-20' => Priority::Low,     // Monday: window passed, 7 days
            '2026-07-21' => Priority::Low,     // Tuesday: 6 days
            '2026-07-22' => Priority::Low,     // Wednesday: 5 days
            '2026-07-23' => Priority::Medium,  // Thursday: 4 days
            '2026-07-24' => Priority::Medium,  // Friday: 3 days
            '2026-07-25' => Priority::High,    // Saturday: 2 days
            '2026-07-26' => Priority::High,    // Sunday: 1 day
        ];

        $task = $this->pendingTask();
        $service = app(PriorityService::class);

        foreach ($expectations as $date => $expected) {
            $this->assertSame(
                $expected,
                $service->compute($task, CarbonImmutable::parse($date)),
                "Wrong priority band on {$date}",
            );
        }
    }

    public function test_due_today_is_urgent_and_overrides_the_band(): void
    {
        // A Wednesday, which would otherwise be Low.
        $today = CarbonImmutable::parse('2026-07-22');
        $task = $this->pendingTask(['due_date' => '2026-07-22']);

        $this->assertSame(
            Priority::Urgent,
            app(PriorityService::class)->compute($task, $today),
        );
    }

    public function test_priority_climbs_as_the_window_approaches(): void
    {
        $task = $this->pendingTask();
        $service = app(PriorityService::class);

        foreach ([
            '2026-07-22' => 'low',
            '2026-07-24' => 'medium',
            '2026-07-25' => 'high',
        ] as $date => $expected) {
            Carbon::setTestNow(Carbon::parse($date.' 00:05:00'));
            $service->refresh();
            $this->assertSame($expected, $task->refresh()->priority->value, "on {$date}");
        }
    }

    public function test_priority_applies_to_queue_states_only(): void
    {
        Carbon::setTestNow(Carbon::parse('2026-07-25 00:05:00'));

        $draft = Task::factory()->createdBy($this->deptHead)->create([
            'status' => TaskStatus::Draft,
        ]);
        $completed = Task::factory()->createdBy($this->deptHead)->create([
            'status' => TaskStatus::Completed,
        ]);
        $pending = $this->pendingTask();

        app(PriorityService::class)->refresh();

        $this->assertNull($draft->refresh()->priority);
        $this->assertNull($completed->refresh()->priority);
        $this->assertSame(Priority::High, $pending->refresh()->priority);
    }

    public function test_overdue_flag_tracks_the_due_date_on_live_states(): void
    {
        Carbon::setTestNow(Carbon::parse('2026-07-22 00:05:00'));

        $overduePending = $this->pendingTask(['due_date' => '2026-07-20']);
        $futurePending = $this->pendingTask(['due_date' => '2026-07-30']);
        $overdueCompleted = Task::factory()->createdBy($this->deptHead)->create([
            'status' => TaskStatus::Completed,
            'due_date' => '2026-07-01',
        ]);

        app(PriorityService::class)->refresh();

        $this->assertTrue($overduePending->refresh()->overdue);
        $this->assertFalse($futurePending->refresh()->overdue);
        // Completed is not a live state; it never carries the flag.
        $this->assertFalse($overdueCompleted->refresh()->overdue);

        // A postponement to a future date clears the flag next run.
        $overduePending->update(['due_date' => '2026-08-05']);
        app(PriorityService::class)->refresh();
        $this->assertFalse($overduePending->refresh()->overdue);
    }

    public function test_task_escalates_after_two_priority_cycles_without_action(): void
    {
        Carbon::setTestNow(Carbon::parse('2026-07-01 09:00:00'));
        $task = $this->pendingTask();
        // Simulate the submission trail so the last action is dated.
        $task->auditEntries()->create([
            'actor_id' => $this->deptHead->id,
            'actor_role' => $this->deptHead->role,
            'company_id' => $task->company_id,
            'from_state' => TaskStatus::Submitted,
            'to_state' => TaskStatus::PendingApproval,
            'via_technical' => false,
            'created_at' => now(),
        ]);

        $service = app(EscalationService::class);

        // Day 13: not yet.
        Carbon::setTestNow(Carbon::parse('2026-07-14 00:15:00'));
        $this->assertSame(0, $service->escalateStale());
        $this->assertSame(TaskStatus::PendingApproval, $task->refresh()->status);

        // Day 14: two full cycles have passed.
        Carbon::setTestNow(Carbon::parse('2026-07-15 00:15:00'));
        $this->assertSame(1, $service->escalateStale());

        $task->refresh();
        $this->assertSame(TaskStatus::Escalated, $task->status);

        // System-driven audit entry with no actor.
        $entry = $task->auditEntries()->orderByDesc('id')->first();
        $this->assertNull($entry->actor_id);
        $this->assertSame(TaskStatus::PendingApproval, $entry->from_state);
        $this->assertSame(TaskStatus::Escalated, $entry->to_state);
        $this->assertStringContainsString('two full priority cycles', $entry->reason);
        $this->assertFalse($entry->via_technical);
    }

    public function test_recent_action_resets_the_escalation_clock(): void
    {
        Carbon::setTestNow(Carbon::parse('2026-07-01 09:00:00'));
        $task = $this->pendingTask();

        // An approver postpones on day 10; the clock restarts.
        Carbon::setTestNow(Carbon::parse('2026-07-11 10:00:00'));
        $task->auditEntries()->create([
            'actor_id' => $this->deptHead->id,
            'actor_role' => Role::CompanyFinance,
            'company_id' => $task->company_id,
            'from_state' => TaskStatus::PendingApproval,
            'to_state' => TaskStatus::Postponed,
            'via_technical' => false,
            'created_at' => now(),
        ]);

        Carbon::setTestNow(Carbon::parse('2026-07-16 00:15:00'));
        $this->assertSame(0, app(EscalationService::class)->escalateStale());
        $this->assertSame(TaskStatus::PendingApproval, $task->refresh()->status);
    }

    public function test_urgent_task_overdue_two_weeks_escalates(): void
    {
        Carbon::setTestNow(Carbon::parse('2026-07-20 00:15:00'));

        // Created recently (stale rule does not apply) but overdue 15 days.
        $task = $this->pendingTask(['due_date' => '2026-07-05']);

        $this->assertSame(1, app(EscalationService::class)->escalateStale());

        $entry = $task->refresh()->auditEntries()->orderByDesc('id')->first();
        $this->assertStringContainsString('overdue', $entry->reason);
    }

    public function test_escalated_task_sits_until_dof_accepts_or_rejects(): void
    {
        $task = $this->pendingTask(['status' => TaskStatus::Escalated]);
        $dof = User::query()->where('role', Role::Dof)->sole();
        $finance = User::query()->where('role', Role::CompanyFinance)->sole();

        // Escalation does not re-trigger; running the job again is a no-op.
        $this->assertSame(0, app(EscalationService::class)->escalateStale());
        $this->assertSame(TaskStatus::Escalated, $task->refresh()->status);

        // Company finance may not resolve an escalated task, even in
        // its own company.
        $ownCompanyTask = Task::factory()
            ->inCompany($finance->company)
            ->create(['status' => TaskStatus::Escalated]);
        $this->actingAs($finance, 'sanctum')
            ->postJson("/api/tasks/{$ownCompanyTask->id}/approve", ['receipt_required' => false])
            ->assertForbidden();

        // The dof accepts: the normal approval flow resumes.
        $this->actingAs($dof, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/approve", ['receipt_required' => false])
            ->assertOk()
            ->assertJsonPath('task.status', 'completed');
    }

    public function test_dof_may_reject_an_escalated_task(): void
    {
        $task = $this->pendingTask(['status' => TaskStatus::Escalated]);
        $dof = User::query()->where('role', Role::Dof)->sole();

        $this->actingAs($dof, 'sanctum')
            ->postJson("/api/tasks/{$task->id}/reject", ['reason' => 'Stale request no longer needed.'])
            ->assertOk()
            ->assertJsonPath('task.status', 'rejected');
    }

    public function test_scheduled_commands_run(): void
    {
        $this->artisan('tasks:refresh-priorities')->assertSuccessful();
        $this->artisan('tasks:escalate')->assertSuccessful();
    }
}
