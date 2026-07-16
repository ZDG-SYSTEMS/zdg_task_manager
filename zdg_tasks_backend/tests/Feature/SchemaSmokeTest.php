<?php

namespace Tests\Feature;

use App\Enums\Role;
use App\Enums\TaskStatus;
use App\Enums\TaskType;
use App\Models\AuditEntry;
use App\Models\Company;
use App\Models\Task;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use LogicException;
use Tests\TestCase;

class SchemaSmokeTest extends TestCase
{
    use RefreshDatabase;

    public function test_seeders_create_companies_and_one_user_per_role(): void
    {
        $this->seed(DatabaseSeeder::class);

        $this->assertSame(
            ['BRI', 'IBS', 'ZDC', 'ZDG', 'ZDL'],
            Company::query()->orderBy('code')->pluck('code')->all(),
        );

        foreach (Role::cases() as $role) {
            $this->assertSame(
                1,
                User::query()->where('role', $role)->count(),
                "Expected exactly one seeded user with role {$role->value}",
            );
        }

        // The dof is the single account based at ZDG.
        $dof = User::query()->where('role', Role::Dof)->sole();
        $this->assertSame('ZDG', $dof->company->code);
    }

    public function test_user_codes_use_company_prefix_and_per_company_sequence(): void
    {
        $this->seed(DatabaseSeeder::class);

        foreach (User::query()->with('company')->get() as $user) {
            $this->assertMatchesRegularExpression(
                '/^'.$user->company->code.'\d{3,}$/',
                $user->code,
            );
        }

        // Sequences advance independently per company.
        $zdg = Company::query()->where('code', 'ZDG')->sole();
        $zdc = Company::query()->where('code', 'ZDC')->sole();
        $this->assertSame('ZDG004', User::nextCodeFor($zdg));
        $this->assertSame('ZDC002', User::nextCodeFor($zdc));
    }

    public function test_task_money_columns_cast_to_integers(): void
    {
        $this->seed(DatabaseSeeder::class);

        $creator = User::query()->where('role', Role::DeptHead)->sole();

        $task = Task::query()->create([
            'type' => TaskType::Standard,
            'title' => 'Stationery restock',
            'description' => 'Quarterly stationery order.',
            'created_by' => $creator->id,
            'company_id' => $creator->company_id,
            'amount_requested' => 1234567,
            'due_date' => now()->addWeek()->toDateString(),
            'beneficiary_type' => 'self',
            'status' => TaskStatus::Draft,
        ]);

        $task->refresh();
        $this->assertIsInt($task->amount_requested);
        $this->assertSame(1234567, $task->amount_requested);
        $this->assertSame(TaskType::Standard, $task->type);
        $this->assertSame(TaskStatus::Draft, $task->status);
        $this->assertSame($creator->id, $task->creator->id);
        $this->assertSame($creator->company_id, $task->company->id);
    }

    public function test_audit_entries_are_immutable(): void
    {
        $this->seed(DatabaseSeeder::class);

        $creator = User::query()->where('role', Role::DeptHead)->sole();
        $task = Task::query()->create([
            'type' => TaskType::Standard,
            'title' => 'Audit target',
            'description' => 'Task used to test audit immutability.',
            'created_by' => $creator->id,
            'company_id' => $creator->company_id,
            'amount_requested' => 1000,
            'status' => TaskStatus::Draft,
        ]);

        $entry = AuditEntry::query()->create([
            'task_id' => $task->id,
            'actor_id' => $creator->id,
            'actor_role' => $creator->role,
            'company_id' => $creator->company_id,
            'from_state' => null,
            'to_state' => TaskStatus::Draft,
            'via_technical' => false,
            'created_at' => now(),
        ]);

        $this->expectException(LogicException::class);
        $entry->update(['reason' => 'tampered']);
    }

    public function test_audit_entries_cannot_be_deleted(): void
    {
        $this->seed(DatabaseSeeder::class);

        $creator = User::query()->where('role', Role::DeptHead)->sole();
        $task = Task::query()->create([
            'type' => TaskType::PettyCash,
            'title' => 'Imprest float',
            'description' => 'Petty cash issue for delete test.',
            'created_by' => $creator->id,
            'company_id' => $creator->company_id,
            'amount_issued' => 50000,
            'recipient_id' => $creator->id,
            'status' => TaskStatus::Completed,
        ]);

        $entry = AuditEntry::query()->create([
            'task_id' => $task->id,
            'actor_id' => $creator->id,
            'actor_role' => $creator->role,
            'company_id' => $creator->company_id,
            'from_state' => null,
            'to_state' => TaskStatus::Completed,
            'via_technical' => true,
            'created_at' => now(),
        ]);

        $this->expectException(LogicException::class);
        $entry->delete();
    }
}
