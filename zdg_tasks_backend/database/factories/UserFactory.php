<?php

namespace Database\Factories;

use App\Enums\Role;
use App\Enums\UserStatus;
use App\Models\Company;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * @extends Factory<User>
 */
class UserFactory extends Factory
{
    /**
     * The current password being used by the factory.
     */
    protected static ?string $password;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            // Unique placeholder; tests that assert the ABC000 format
            // should generate codes through User::nextCodeFor().
            'code' => strtoupper(Str::random(3)).fake()->unique()->numerify('###'),
            'name' => fake()->name(),
            'email' => fake()->unique()->safeEmail(),
            'email_verified_at' => now(),
            'password' => static::$password ??= Hash::make('password'),
            'remember_token' => Str::random(10),
            'company_id' => Company::factory(),
            'department' => fake()->randomElement(['Finance', 'Operations', 'IT', 'Procurement']),
            'branch' => null,
            'position' => fake()->jobTitle(),
            'role' => Role::DeptHead,
            'status' => UserStatus::Active,
        ];
    }

    public function role(Role $role): static
    {
        return $this->state(fn (array $attributes) => ['role' => $role]);
    }

    public function inCompany(Company $company): static
    {
        return $this->state(fn (array $attributes) => ['company_id' => $company->id]);
    }

    /**
     * Indicate that the model's email address should be unverified.
     */
    public function unverified(): static
    {
        return $this->state(fn (array $attributes) => [
            'email_verified_at' => null,
        ]);
    }
}
