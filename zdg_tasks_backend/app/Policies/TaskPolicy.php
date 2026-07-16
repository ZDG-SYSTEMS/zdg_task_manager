<?php

namespace App\Policies;

use App\Enums\Role;
use App\Enums\TaskStatus;
use App\Enums\TaskType;
use App\Models\Task;
use App\Models\User;

/**
 * Server-side enforcement of the CLAUDE.md permission matrix. The
 * client only hides controls; every decision here is authoritative.
 *
 * Technical passes most gates so it can exercise features, but every
 * technical action (except user management) must be written with
 * via_technical = true and re-queued by the acting service - a
 * technical pass here is never a genuine authorization. Technical can
 * never fund.
 */
class TaskPolicy
{
    public function view(User $user, Task $task): bool
    {
        return match ($user->role) {
            Role::Technical, Role::Dof, Role::Auditor => true,
            Role::Director, Role::CompanyFinance => $task->company_id === $user->company_id,
            Role::DeptHead => $task->created_by === $user->id || $task->recipient_id === $user->id,
            default => false,
        };
    }

    public function create(User $user, TaskType $type): bool
    {
        return match ($type) {
            TaskType::Standard => $user->role !== null && $user->role !== Role::Auditor,
            TaskType::PettyCash => in_array(
                $user->role,
                [Role::Technical, Role::Dof, Role::CompanyFinance],
                true,
            ),
        };
    }

    /**
     * Drafts are editable until submitted; rejected requests reopen
     * for editing ahead of resubmission.
     */
    public function update(User $user, Task $task): bool
    {
        return $this->ownsEditable($user, $task);
    }

    public function submit(User $user, Task $task): bool
    {
        return $task->status === TaskStatus::Draft
            && ($task->created_by === $user->id || $user->role === Role::Technical);
    }

    public function resubmit(User $user, Task $task): bool
    {
        return $task->status === TaskStatus::Rejected
            && ($task->created_by === $user->id || $user->role === Role::Technical);
    }

    /** Quotations and invoices attach while the request is editable. */
    public function attach(User $user, Task $task): bool
    {
        return $this->ownsEditable($user, $task);
    }

    public function approve(User $user, Task $task): bool
    {
        return $this->actsAsApprover($user, $task);
    }

    public function reject(User $user, Task $task): bool
    {
        return $this->actsAsApprover($user, $task);
    }

    public function postpone(User $user, Task $task): bool
    {
        return $this->actsAsApprover($user, $task);
    }

    public function editAmount(User $user, Task $task): bool
    {
        return $this->actsAsApprover($user, $task);
    }

    public function setReceiptRequired(User $user, Task $task): bool
    {
        return $this->actsAsApprover($user, $task);
    }

    /** Approve-and-assign to a company finance user: dof only. */
    public function assign(User $user, Task $task): bool
    {
        return $user->role === Role::Dof || $user->role === Role::Technical;
    }

    /**
     * Mark-as-funded. Technical never funds - no exception, not even
     * flagged.
     */
    public function fund(User $user, Task $task): bool
    {
        return match ($user->role) {
            Role::Dof => true,
            Role::CompanyFinance => $task->company_id === $user->company_id,
            default => false,
        };
    }

    /**
     * Upload receipts as the person accounting for money: the petty
     * cash recipient, or the creator of a standard request awaiting
     * proof of purchase.
     */
    public function uploadReceipt(User $user, Task $task): bool
    {
        if ($user->role === null || $user->role === Role::Auditor) {
            return false;
        }

        if ($user->role === Role::Technical) {
            return true;
        }

        return $task->recipient_id === $user->id || $task->created_by === $user->id;
    }

    public function verifyReceipts(User $user, Task $task): bool
    {
        return $this->actsAsApprover($user, $task);
    }

    /**
     * The creator works their own draft or rejected request; technical
     * may exercise the flow anywhere but is always tamper-flagged
     * downstream.
     */
    private function ownsEditable(User $user, Task $task): bool
    {
        if (! in_array($task->status, [TaskStatus::Draft, TaskStatus::Rejected], true)) {
            return false;
        }

        return $task->created_by === $user->id || $user->role === Role::Technical;
    }

    /**
     * dof acts across all companies; company_finance only within its
     * own; technical passes but is always tamper-flagged downstream.
     * An escalated task sits on the dof queue: only the dof (or
     * flagged technical) may resolve it.
     */
    private function actsAsApprover(User $user, Task $task): bool
    {
        if ($task->status === TaskStatus::Escalated) {
            return $user->role === Role::Dof || $user->role === Role::Technical;
        }

        return match ($user->role) {
            Role::Technical, Role::Dof => true,
            Role::CompanyFinance => $task->company_id === $user->company_id,
            default => false,
        };
    }
}
