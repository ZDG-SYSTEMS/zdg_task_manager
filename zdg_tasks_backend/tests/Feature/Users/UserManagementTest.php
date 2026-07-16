<?php

namespace Tests\Feature\Users;

use App\Enums\Role;
use App\Enums\UserStatus;
use App\Models\Company;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class UserManagementTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(DatabaseSeeder::class);
    }

    private function userWithRole(Role $role): User
    {
        return User::query()->where('role', $role)->sole();
    }

    public function test_only_technical_can_list_create_update_delete_users(): void
    {
        // Role null so this subject never collides with the seeded
        // one-user-per-role set that userWithRole() resolves.
        $subject = User::factory()->create(['role' => null]);
        $company = Company::query()->where('code', 'ZDL')->sole();

        $nonTechnicalRoles = [
            Role::Director, Role::Dof, Role::CompanyFinance,
            Role::DeptHead, Role::Auditor,
        ];

        foreach ($nonTechnicalRoles as $role) {
            $actor = $this->userWithRole($role);

            $this->actingAs($actor, 'sanctum')
                ->getJson('/api/users')
                ->assertForbidden();

            $this->actingAs($actor, 'sanctum')
                ->postJson('/api/users', [
                    'name' => 'Blocked Creation',
                    'email' => "blocked-{$role->value}@zdg.test",
                    'password' => 'secret-password-1',
                    'company_id' => $company->id,
                    'department' => 'Finance',
                    'position' => 'Officer',
                    'role' => Role::DeptHead->value,
                ])
                ->assertForbidden();

            $this->actingAs($actor, 'sanctum')
                ->patchJson("/api/users/{$subject->id}", ['name' => 'Hacked'])
                ->assertForbidden();

            $this->actingAs($actor, 'sanctum')
                ->deleteJson("/api/users/{$subject->id}")
                ->assertForbidden();
        }
    }

    public function test_technical_has_full_user_crud(): void
    {
        $technical = $this->userWithRole(Role::Technical);
        $company = Company::query()->where('code', 'IBS')->sole();

        $this->actingAs($technical, 'sanctum')
            ->getJson('/api/users')
            ->assertOk();

        $created = $this->actingAs($technical, 'sanctum')
            ->postJson('/api/users', [
                'name' => 'Created By Technical',
                'email' => 'created@zdg.test',
                'password' => 'secret-password-1',
                'company_id' => $company->id,
                'department' => 'Stores',
                'position' => 'Storekeeper',
                'role' => Role::DeptHead->value,
            ])
            ->assertCreated();

        $userId = $created->json('user.id');
        $user = User::query()->findOrFail($userId);
        $this->assertMatchesRegularExpression('/^IBS\d{3,}$/', $user->code);
        $this->assertSame(UserStatus::Active, $user->status);

        $this->actingAs($technical, 'sanctum')
            ->patchJson("/api/users/{$userId}", ['position' => 'Senior Storekeeper'])
            ->assertOk();
        $this->assertSame('Senior Storekeeper', $user->refresh()->position);

        $this->actingAs($technical, 'sanctum')
            ->deleteJson("/api/users/{$userId}")
            ->assertOk();
        $this->assertNull(User::query()->find($userId));
    }

    public function test_technical_cannot_delete_own_account(): void
    {
        $technical = $this->userWithRole(Role::Technical);

        $this->actingAs($technical, 'sanctum')
            ->deleteJson("/api/users/{$technical->id}")
            ->assertUnprocessable();
    }

    public function test_users_can_view_their_own_record_but_not_others(): void
    {
        $deptHead = $this->userWithRole(Role::DeptHead);
        $auditor = $this->userWithRole(Role::Auditor);

        $this->actingAs($deptHead, 'sanctum')
            ->getJson("/api/users/{$deptHead->id}")
            ->assertOk();

        $this->actingAs($deptHead, 'sanctum')
            ->getJson("/api/users/{$auditor->id}")
            ->assertForbidden();
    }
}
