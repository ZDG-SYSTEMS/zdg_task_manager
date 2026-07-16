<?php

namespace Tests\Feature\Auth;

use App\Enums\Role;
use App\Enums\UserStatus;
use App\Models\Company;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthFlowTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(DatabaseSeeder::class);
    }

    private function technical(): User
    {
        return User::query()->where('role', Role::Technical)->sole();
    }

    public function test_registration_creates_pending_account_without_role(): void
    {
        $company = Company::query()->where('code', 'ZDG')->sole();

        $response = $this->postJson('/api/auth/register', [
            'name' => 'New Registrant',
            'email' => 'registrant@zdg.test',
            'password' => 'secret-password-1',
            'password_confirmation' => 'secret-password-1',
            'company_id' => $company->id,
            'department' => 'Procurement',
            'position' => 'Officer',
        ]);

        $response->assertCreated();

        $user = User::query()->where('email', 'registrant@zdg.test')->sole();
        $this->assertNull($user->role);
        $this->assertSame(UserStatus::Inactive, $user->status);
        $this->assertMatchesRegularExpression('/^ZDG\d{3,}$/', $user->code);
    }

    public function test_registration_never_accepts_a_role_or_status(): void
    {
        $company = Company::query()->where('code', 'ZDC')->sole();

        $this->postJson('/api/auth/register', [
            'name' => 'Sneaky Registrant',
            'email' => 'sneaky@zdg.test',
            'password' => 'secret-password-1',
            'password_confirmation' => 'secret-password-1',
            'company_id' => $company->id,
            'department' => 'Finance',
            'position' => 'Officer',
            'role' => Role::Dof->value,
            'status' => UserStatus::Active->value,
        ])->assertCreated();

        $user = User::query()->where('email', 'sneaky@zdg.test')->sole();
        $this->assertNull($user->role);
        $this->assertSame(UserStatus::Inactive, $user->status);
    }

    public function test_pending_account_cannot_login_until_role_assigned(): void
    {
        $company = Company::query()->where('code', 'ZDG')->sole();
        $pending = User::factory()->inCompany($company)->create([
            'role' => null,
            'status' => UserStatus::Inactive,
            'password' => 'secret-password-1',
        ]);

        $this->postJson('/api/auth/login', [
            'email' => $pending->email,
            'password' => 'secret-password-1',
        ])->assertForbidden();

        // Technical assigns a role, which activates the account.
        $this->actingAs($this->technical(), 'sanctum')
            ->patchJson("/api/users/{$pending->id}", ['role' => Role::DeptHead->value])
            ->assertOk();

        $pending->refresh();
        $this->assertSame(Role::DeptHead, $pending->role);
        $this->assertSame(UserStatus::Active, $pending->status);

        $this->postJson('/api/auth/login', [
            'email' => $pending->email,
            'password' => 'secret-password-1',
        ])->assertOk()->assertJsonStructure(['token', 'user']);
    }

    public function test_login_rejects_bad_credentials(): void
    {
        $this->postJson('/api/auth/login', [
            'email' => 'dof@zdg.test',
            'password' => 'wrong-password',
        ])->assertUnprocessable();
    }

    public function test_logout_revokes_the_token(): void
    {
        $login = $this->postJson('/api/auth/login', [
            'email' => 'dof@zdg.test',
            'password' => 'password',
        ])->assertOk();

        $token = $login->json('token');
        $headers = ['Authorization' => "Bearer {$token}"];

        $this->getJson('/api/auth/me', $headers)->assertOk();
        $this->postJson('/api/auth/logout', [], $headers)->assertOk();

        // Clear the guard cache so the next request re-resolves the token.
        $this->app['auth']->forgetGuards();

        $this->getJson('/api/auth/me', $headers)->assertUnauthorized();
    }

    public function test_deactivated_user_is_blocked_by_middleware(): void
    {
        $user = User::factory()->create(['password' => 'secret-password-1']);
        $token = $user->createToken('api')->plainTextToken;
        $headers = ['Authorization' => "Bearer {$token}"];

        $this->getJson('/api/auth/me', $headers)->assertOk();

        $user->update(['status' => UserStatus::Inactive]);

        // Clear the guard cache so the middleware sees the fresh status.
        $this->app['auth']->forgetGuards();

        $this->getJson('/api/auth/me', $headers)->assertForbidden();
    }

    public function test_self_edit_allows_only_name_email_password(): void
    {
        $user = User::factory()->create([
            'password' => 'secret-password-1',
            'department' => 'Operations',
        ]);

        $this->actingAs($user, 'sanctum')->patchJson('/api/auth/me', [
            'name' => 'Renamed User',
            'email' => 'renamed@zdg.test',
            'department' => 'Finance',
            'role' => Role::Dof->value,
        ])->assertOk();

        $user->refresh();
        $this->assertSame('Renamed User', $user->name);
        $this->assertSame('renamed@zdg.test', $user->email);
        // Unlisted fields are silently discarded, never applied.
        $this->assertSame('Operations', $user->department);
        $this->assertNotSame(Role::Dof, $user->role);
    }

    public function test_password_change_requires_current_password(): void
    {
        $user = User::factory()->create(['password' => 'secret-password-1']);

        $this->actingAs($user, 'sanctum')->patchJson('/api/auth/me', [
            'password' => 'new-password-123',
            'password_confirmation' => 'new-password-123',
        ])->assertUnprocessable();

        $this->actingAs($user, 'sanctum')->patchJson('/api/auth/me', [
            'password' => 'new-password-123',
            'password_confirmation' => 'new-password-123',
            'current_password' => 'secret-password-1',
        ])->assertOk();

        $this->postJson('/api/auth/login', [
            'email' => $user->email,
            'password' => 'new-password-123',
        ])->assertOk();
    }

    public function test_companies_endpoint_feeds_registration_dropdown(): void
    {
        $this->getJson('/api/companies')
            ->assertOk()
            ->assertJsonCount(5, 'companies')
            ->assertJsonPath('companies.0.code', 'BRI');
    }
}
