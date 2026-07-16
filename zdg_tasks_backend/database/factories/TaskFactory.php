<?php

namespace Database\Factories;

use App\Enums\TaskStatus;
use App\Enums\TaskType;
use App\Models\Company;
use App\Models\Task;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Task>
 */
class TaskFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'type' => TaskType::Standard,
            'title' => fake()->sentence(4),
            'description' => fake()->paragraph(),
            'created_by' => User::factory(),
            'company_id' => Company::factory(),
            'amount_requested' => fake()->numberBetween(10_000, 5_000_000),
            'currency' => 'ZMW',
            'due_date' => fake()->dateTimeBetween('+1 day', '+3 weeks')->format('Y-m-d'),
            'beneficiary_type' => 'self',
            'status' => TaskStatus::PendingApproval,
        ];
    }

    public function pettyCash(User $recipient): static
    {
        return $this->state(fn (array $attributes) => [
            'type' => TaskType::PettyCash,
            'amount_requested' => null,
            'beneficiary_type' => null,
            'due_date' => null,
            'amount_issued' => fake()->numberBetween(10_000, 500_000),
            'recipient_id' => $recipient->id,
            'status' => TaskStatus::PendingReceipt,
        ]);
    }

    public function inCompany(Company $company): static
    {
        return $this->state(fn (array $attributes) => ['company_id' => $company->id]);
    }

    public function createdBy(User $user): static
    {
        return $this->state(fn (array $attributes) => [
            'created_by' => $user->id,
            'company_id' => $user->company_id,
        ]);
    }
}
