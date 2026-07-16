<?php

namespace Tests\Feature\Authorization;

use App\Enums\Role;
use App\Enums\TaskType;
use App\Models\Company;
use App\Models\Task;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Gate;
use Tests\TestCase;

/**
 * Asserts the CLAUDE.md permission matrix cell by cell: each role can
 * do exactly what the matrix allows and nothing more.
 *
 * Seeded actors: technical at ZDG, director at ZDL, dof at ZDG,
 * company_finance at ZDC, dept_head at IBS, auditor at ZDG.
 */
class TaskPolicyMatrixTest extends TestCase
{
    use RefreshDatabase;

    /** @var array<string, User> */
    private array $actors;

    private Task $taskInZdc;

    private Task $taskInZdl;

    private Task $deptHeadOwnTask;

    private Task $pettyCashForDeptHead;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(DatabaseSeeder::class);

        foreach (Role::cases() as $role) {
            $this->actors[$role->value] = User::query()->where('role', $role)->sole();
        }

        $zdc = Company::query()->where('code', 'ZDC')->sole();
        $zdl = Company::query()->where('code', 'ZDL')->sole();

        $this->taskInZdc = Task::factory()->inCompany($zdc)->create();
        $this->taskInZdl = Task::factory()->inCompany($zdl)->create();
        $this->deptHeadOwnTask = Task::factory()
            ->createdBy($this->actors[Role::DeptHead->value])
            ->create();
        $this->pettyCashForDeptHead = Task::factory()
            ->pettyCash($this->actors[Role::DeptHead->value])
            ->inCompany($this->actors[Role::DeptHead->value]->company)
            ->create();
    }

    /**
     * @param  array<string, bool>  $expectations  role value => allowed
     */
    private function assertMatrix(string $ability, mixed $arguments, array $expectations): void
    {
        foreach ($expectations as $roleValue => $allowed) {
            $actor = $this->actors[$roleValue];
            $this->assertSame(
                $allowed,
                Gate::forUser($actor)->allows($ability, $arguments),
                "Expected {$roleValue} ".($allowed ? 'to be allowed' : 'to be denied')." '{$ability}'.",
            );
        }
    }

    public function test_view_scope_matrix(): void
    {
        // A task in ZDC: cross-company roles see it, ZDL director and
        // IBS dept head do not, ZDC finance does.
        $this->assertMatrix('view', $this->taskInZdc, [
            'technical' => true,
            'director' => false,
            'dof' => true,
            'company_finance' => true,
            'dept_head' => false,
            'auditor' => true,
        ]);

        // A task in ZDL: the ZDL director sees it, ZDC finance does not.
        $this->assertMatrix('view', $this->taskInZdl, [
            'technical' => true,
            'director' => true,
            'dof' => true,
            'company_finance' => false,
            'dept_head' => false,
            'auditor' => true,
        ]);

        // Dept head sees own created task and own petty cash.
        $this->assertTrue(
            Gate::forUser($this->actors['dept_head'])->allows('view', $this->deptHeadOwnTask)
        );
        $this->assertTrue(
            Gate::forUser($this->actors['dept_head'])->allows('view', $this->pettyCashForDeptHead)
        );
    }

    public function test_create_standard_request_matrix(): void
    {
        $this->assertMatrix('create', [Task::class, TaskType::Standard], [
            'technical' => true,
            'director' => true,
            'dof' => true,
            'company_finance' => true,
            'dept_head' => true,
            'auditor' => false,
        ]);
    }

    public function test_create_petty_cash_matrix(): void
    {
        $this->assertMatrix('create', [Task::class, TaskType::PettyCash], [
            'technical' => true,
            'director' => false,
            'dof' => true,
            'company_finance' => true,
            'dept_head' => false,
            'auditor' => false,
        ]);
    }

    public function test_approval_actions_matrix(): void
    {
        foreach (['approve', 'reject', 'postpone', 'editAmount', 'setReceiptRequired', 'verifyReceipts'] as $ability) {
            // Own-company task for the ZDC finance user.
            $this->assertMatrix($ability, $this->taskInZdc, [
                'technical' => true,
                'director' => false,
                'dof' => true,
                'company_finance' => true,
                'dept_head' => false,
                'auditor' => false,
            ]);

            // Cross-company: only dof (and flagged technical) may act.
            $this->assertMatrix($ability, $this->taskInZdl, [
                'technical' => true,
                'director' => false,
                'dof' => true,
                'company_finance' => false,
                'dept_head' => false,
                'auditor' => false,
            ]);
        }
    }

    public function test_assign_matrix(): void
    {
        $this->assertMatrix('assign', $this->taskInZdc, [
            'technical' => true,
            'director' => false,
            'dof' => true,
            'company_finance' => false,
            'dept_head' => false,
            'auditor' => false,
        ]);
    }

    public function test_fund_matrix_and_technical_never_funds(): void
    {
        // Own company for ZDC finance.
        $this->assertMatrix('fund', $this->taskInZdc, [
            'technical' => false,
            'director' => false,
            'dof' => true,
            'company_finance' => true,
            'dept_head' => false,
            'auditor' => false,
        ]);

        // Cross-company: dof only. Technical never funds anywhere.
        $this->assertMatrix('fund', $this->taskInZdl, [
            'technical' => false,
            'director' => false,
            'dof' => true,
            'company_finance' => false,
            'dept_head' => false,
            'auditor' => false,
        ]);
    }

    public function test_upload_receipt_matrix(): void
    {
        // Petty cash issued to the dept head: recipient uploads;
        // uninvolved roles and the auditor never do.
        $this->assertMatrix('uploadReceipt', $this->pettyCashForDeptHead, [
            'technical' => true,
            'director' => false,
            'dof' => false,
            'company_finance' => false,
            'dept_head' => true,
            'auditor' => false,
        ]);

        // Creator of a standard task may upload proof of purchase.
        $this->assertTrue(
            Gate::forUser($this->actors['dept_head'])->allows('uploadReceipt', $this->deptHeadOwnTask)
        );
    }

    public function test_reports_gate_matrix(): void
    {
        $expectations = [
            'technical' => true,
            'director' => false,
            'dof' => true,
            'company_finance' => true,
            'dept_head' => false,
            'auditor' => true,
        ];

        foreach ($expectations as $roleValue => $allowed) {
            $this->assertSame(
                $allowed,
                Gate::forUser($this->actors[$roleValue])->allows('generate-reports'),
                "Expected {$roleValue} reports access to be ".var_export($allowed, true),
            );
        }
    }

    public function test_user_without_role_can_do_nothing(): void
    {
        $pending = User::factory()->create(['role' => null]);

        $this->assertFalse(Gate::forUser($pending)->allows('view', $this->taskInZdc));
        $this->assertFalse(Gate::forUser($pending)->allows('create', [Task::class, TaskType::Standard]));
        $this->assertFalse(Gate::forUser($pending)->allows('approve', $this->taskInZdc));
        $this->assertFalse(Gate::forUser($pending)->allows('fund', $this->taskInZdc));
        $this->assertFalse(Gate::forUser($pending)->allows('generate-reports'));
    }

    public function test_visible_to_scope_matches_view_policy(): void
    {
        // Four tasks exist. Cross-company roles see all of them.
        foreach (['technical', 'dof', 'auditor'] as $roleValue) {
            $this->assertSame(
                4,
                Task::query()->visibleTo($this->actors[$roleValue])->count(),
                "{$roleValue} should see every task",
            );
        }

        // ZDL director sees only the ZDL task.
        $this->assertSame(
            [$this->taskInZdl->id],
            Task::query()->visibleTo($this->actors['director'])->pluck('id')->all(),
        );

        // ZDC finance sees only the ZDC task.
        $this->assertSame(
            [$this->taskInZdc->id],
            Task::query()->visibleTo($this->actors['company_finance'])->pluck('id')->all(),
        );

        // Dept head sees exactly their own created task and their petty cash.
        $this->assertEqualsCanonicalizing(
            [$this->deptHeadOwnTask->id, $this->pettyCashForDeptHead->id],
            Task::query()->visibleTo($this->actors['dept_head'])->pluck('id')->all(),
        );
    }
}
