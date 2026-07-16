<?php

namespace App\Policies;

use App\Enums\Role;
use App\Models\User;

class UserPolicy
{
    /**
     * Only technical manages accounts (CLAUDE.md). Everyone edits their
     * own profile through the dedicated /auth/me endpoint, which limits
     * the fields; this policy governs the /users resource.
     */
    public function viewAny(User $user): bool
    {
        return $user->role === Role::Technical;
    }

    public function view(User $user, User $subject): bool
    {
        return $user->role === Role::Technical || $user->is($subject);
    }

    public function create(User $user): bool
    {
        return $user->role === Role::Technical;
    }

    public function update(User $user, User $subject): bool
    {
        return $user->role === Role::Technical;
    }

    public function delete(User $user, User $subject): bool
    {
        return $user->role === Role::Technical;
    }
}
