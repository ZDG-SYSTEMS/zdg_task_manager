<?php

namespace App\Policies;

use App\Enums\Role;
use App\Models\Budget;
use App\Models\User;

/**
 * Budgets are optional and set by finance: company_finance for its own
 * company, dof across all companies (CLAUDE.md).
 */
class BudgetPolicy
{
    public function viewAny(User $user): bool
    {
        return in_array($user->role, [Role::CompanyFinance, Role::Dof, Role::Technical, Role::Auditor], true);
    }

    public function create(User $user): bool
    {
        return in_array($user->role, [Role::CompanyFinance, Role::Dof], true);
    }

    public function update(User $user, Budget $budget): bool
    {
        return $this->manages($user, $budget);
    }

    public function delete(User $user, Budget $budget): bool
    {
        return $this->manages($user, $budget);
    }

    private function manages(User $user, Budget $budget): bool
    {
        return match ($user->role) {
            Role::Dof => true,
            Role::CompanyFinance => $budget->company_id === $user->company_id,
            default => false,
        };
    }
}
