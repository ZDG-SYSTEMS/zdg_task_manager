<?php

namespace Tests\Feature\Dashboard;

use App\Enums\Role;
use App\Enums\TaskStatus;
use App\Models\Company;
use App\Models\Task;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DashboardAndListTest extends TestCase
{
    use RefreshDatabase;

    private User $deptHead;

    private User $ibsFinance;

    private User $dof;

    private Company $ibs;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(DatabaseSeeder::class);

        $this->deptHead = User::query()->where('role', Role::DeptHead)->sole();
        $this->dof = User::query()->where('role', Role::Dof)->sole();
        $this->ibs = $this->deptHead->company;
        $this->ibsFinance = User::factory()
            ->role(Role::CompanyFinance)
            ->inCompany($this->ibs)
            ->create();
    }

    public function test_dashboard_counts_are_scoped_to_the_viewer(): void
    {
        $zdl = Company::query()->where('code', 'ZDL')->sole();

        // Three IBS tasks in different states, one of them overdue,
        // plus one ZDL task invisible to IBS viewers.
        Task::factory()->createdBy($this->deptHead)->create([
            'status' => TaskStatus::PendingApproval,
            'overdue' => true,
        ]);
        Task::factory()->createdBy($this->deptHead)->create([
            'status' => TaskStatus::PendingReceipt,
            'assigned_funder_id' => $this->ibsFinance->id,
        ]);
        Task::factory()->createdBy($this->deptHead)->create(['status' => TaskStatus::Completed]);
        Task::factory()->inCompany($zdl)->create(['status' => TaskStatus::PendingApproval]);

        // IBS finance sees exactly the three IBS tasks.
        $this->actingAs($this->ibsFinance, 'sanctum')
            ->getJson('/api/dashboard')
            ->assertOk()
            ->assertJsonPath('counts.total', 3)
            ->assertJsonPath('counts.pending', 1)
            ->assertJsonPath('counts.in_progress', 1)
            ->assertJsonPath('counts.assigned', 1)
            ->assertJsonPath('counts.overdue', 1);

        // The dof sees everything.
        $this->actingAs($this->dof, 'sanctum')
            ->getJson('/api/dashboard')
            ->assertOk()
            ->assertJsonPath('counts.total', 4)
            ->assertJsonPath('counts.pending', 2);

        // The dept head sees only their own tasks.
        $this->actingAs($this->deptHead, 'sanctum')
            ->getJson('/api/dashboard')
            ->assertOk()
            ->assertJsonPath('counts.total', 3);
    }

    public function test_budget_position_is_computed_from_funded_amounts_in_period(): void
    {
        $this->actingAs($this->ibsFinance, 'sanctum')->postJson('/api/budgets', [
            'company_id' => $this->ibs->id,
            'department' => $this->deptHead->department,
            'period_type' => 'monthly',
            'period_start' => now()->startOfMonth()->toDateString(),
            'period_end' => now()->endOfMonth()->toDateString(),
            'amount' => 1000000,
        ])->assertCreated();

        // Two funded tasks by this department this period, one outside
        // the period, one from another department.
        Task::factory()->createdBy($this->deptHead)->create([
            'status' => TaskStatus::Completed,
            'funded' => true, 'funded_amount' => 300000, 'funded_at' => now(),
        ]);
        Task::factory()->createdBy($this->deptHead)->create([
            'status' => TaskStatus::Completed,
            'funded' => true, 'funded_amount' => 150000, 'funded_at' => now(),
        ]);
        Task::factory()->createdBy($this->deptHead)->create([
            'status' => TaskStatus::Completed,
            'funded' => true, 'funded_amount' => 999999, 'funded_at' => now()->subMonths(2),
        ]);
        $otherDept = User::factory()->inCompany($this->ibs)->create(['department' => 'Marketing']);
        Task::factory()->createdBy($otherDept)->create([
            'status' => TaskStatus::Completed,
            'funded' => true, 'funded_amount' => 888888, 'funded_at' => now(),
        ]);

        // The department member sees their own department's position.
        $response = $this->actingAs($this->deptHead, 'sanctum')->getJson('/api/dashboard')->assertOk();
        $budget = $response->json('budgets.0');
        $this->assertSame(1000000, $budget['amount']);
        $this->assertSame(450000, $budget['funded_to_date']);
        $this->assertSame(550000, $budget['remaining']);
        $this->assertCount(1, $response->json('budgets'));
    }

    public function test_no_budget_means_no_budget_ui(): void
    {
        $this->actingAs($this->deptHead, 'sanctum')
            ->getJson('/api/dashboard')
            ->assertOk()
            ->assertJsonPath('budgets', []);
    }

    public function test_budget_setting_is_scoped_to_finance(): void
    {
        $zdl = Company::query()->where('code', 'ZDL')->sole();
        $payload = [
            'company_id' => $zdl->id,
            'department' => 'Operations',
            'period_type' => 'monthly',
            'period_start' => now()->startOfMonth()->toDateString(),
            'period_end' => now()->endOfMonth()->toDateString(),
            'amount' => 500000,
        ];

        // A dept head can never set budgets.
        $this->actingAs($this->deptHead, 'sanctum')
            ->postJson('/api/budgets', $payload)
            ->assertForbidden();

        // Company finance cannot set one for another company.
        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson('/api/budgets', $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors('company_id');

        // The dof sets budgets across all companies.
        $this->actingAs($this->dof, 'sanctum')
            ->postJson('/api/budgets', $payload)
            ->assertCreated();

        // Duplicate department and period is refused.
        $this->actingAs($this->dof, 'sanctum')
            ->postJson('/api/budgets', $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors('department');
    }

    public function test_task_list_searches_and_filters(): void
    {
        Task::factory()->createdBy($this->deptHead)->create([
            'title' => 'Projector replacement',
            'status' => TaskStatus::PendingApproval,
            'priority' => 'high',
        ]);
        Task::factory()->createdBy($this->deptHead)->create([
            'title' => 'Stationery order',
            'status' => TaskStatus::PendingApproval,
            'priority' => 'low',
        ]);

        // Free-text search on title.
        $this->actingAs($this->ibsFinance, 'sanctum')
            ->getJson('/api/tasks?q=projector')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.title', 'Projector replacement');

        // Search by creator name.
        $this->actingAs($this->ibsFinance, 'sanctum')
            ->getJson('/api/tasks?q='.urlencode($this->deptHead->name))
            ->assertOk()
            ->assertJsonCount(2, 'data');

        // Priority filter works for approvers.
        $this->actingAs($this->ibsFinance, 'sanctum')
            ->getJson('/api/tasks?priority=high')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.priority', 'high');

        // The same filter is ignored for the requester, and priority
        // stays hidden from their rows.
        $response = $this->actingAs($this->deptHead, 'sanctum')
            ->getJson('/api/tasks?priority=high')
            ->assertOk();
        $this->assertCount(2, $response->json('data'));
        $this->assertArrayNotHasKey('priority', $response->json('data.0'));
    }

    public function test_list_rows_carry_name_and_location_columns(): void
    {
        $this->deptHead->update(['branch' => 'Lusaka HQ']);
        Task::factory()->createdBy($this->deptHead)->create(['status' => TaskStatus::PendingApproval]);

        $this->actingAs($this->ibsFinance, 'sanctum')
            ->getJson('/api/tasks')
            ->assertOk()
            ->assertJsonPath('data.0.creator.name', $this->deptHead->name)
            ->assertJsonPath('data.0.creator.branch', 'Lusaka HQ')
            ->assertJsonPath('data.0.company.code', $this->ibs->code);
    }
}
