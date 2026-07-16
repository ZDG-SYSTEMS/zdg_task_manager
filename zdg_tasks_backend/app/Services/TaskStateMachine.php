<?php

namespace App\Services;

use App\Enums\BeneficiaryType;
use App\Enums\Role;
use App\Enums\TaskStatus;
use App\Exceptions\InvalidTransitionException;
use App\Models\AuditEntry;
use App\Models\Task;
use App\Models\User;
use Illuminate\Validation\ValidationException;

/**
 * The single gateway for task state changes. Every transition is
 * guarded against the allowed map and writes an immutable audit entry;
 * no other code path may change a task's status.
 */
class TaskStateMachine
{
    /**
     * Allowed transitions. Later phases extend this map as their
     * actions land (approval, rejection, postponement, receipts,
     * escalation); a state never listed here is unreachable.
     *
     * @var array<string, list<TaskStatus>>
     */
    private const TRANSITIONS = [
        'draft' => [TaskStatus::Submitted],
        'submitted' => [TaskStatus::PendingApproval],
        'pending_approval' => [TaskStatus::Approved, TaskStatus::Rejected, TaskStatus::Postponed, TaskStatus::Escalated],
        // Postponed is a transient through-state: the same record
        // returns to pending_approval with its new due date.
        'postponed' => [TaskStatus::PendingApproval],
        // approved -> pending_approval is the technical re-queue path.
        'approved' => [TaskStatus::PendingReceipt, TaskStatus::Completed, TaskStatus::PendingApproval],
        // rejected -> pending_approval covers resubmission and the
        // technical re-queue.
        'rejected' => [TaskStatus::PendingApproval],
        'pending_receipt' => [TaskStatus::Completed],
        // Stale or long-overdue queue items escalate to the dof, who
        // holds them indefinitely until accepting or rejecting.
        'escalated' => [TaskStatus::Approved, TaskStatus::Rejected],
    ];

    /**
     * A draft may be saved incomplete, but submission requires every
     * field of the standard request form. Field errors surface as 422
     * so the client can block inline instead of auto-drafting.
     */
    public function assertReadyForSubmission(Task $task): void
    {
        $errors = [];

        if (blank($task->description)) {
            $errors['description'][] = 'A description is required.';
        } elseif (count(preg_split('/\s+/', trim($task->description), -1, PREG_SPLIT_NO_EMPTY)) > 150) {
            $errors['description'][] = 'The description may not exceed 150 words.';
        }

        if ($task->amount_requested === null || $task->amount_requested < 1) {
            $errors['amount_requested'][] = 'An amount in ZMW is required.';
        }

        if ($task->due_date === null) {
            $errors['due_date'][] = 'A due date is required.';
        }

        if ($task->beneficiary_type === null) {
            $errors['beneficiary_type'][] = 'Select who the request is for.';
        } elseif ($task->beneficiary_type === BeneficiaryType::Other && blank($task->beneficiary_name)) {
            $errors['beneficiary_name'][] = 'A beneficiary name is required when requesting for someone else.';
        }

        if ($errors !== []) {
            throw ValidationException::withMessages($errors);
        }
    }

    /** Writes the creation entry (no from-state) for a new task. */
    public function recordCreation(Task $task, User $actor): void
    {
        $this->writeAudit($task, $actor, null, $task->status);
    }

    /** A null actor marks a system-driven transition (scheduled jobs). */
    public function transition(Task $task, TaskStatus $to, ?User $actor, ?string $reason = null): void
    {
        $from = $task->status;

        if (! in_array($to, self::TRANSITIONS[$from->value] ?? [], true)) {
            throw new InvalidTransitionException($from, $to);
        }

        // A technical action permanently tamper-flags the record; it is
        // never a genuine authorization.
        if ($actor?->role === Role::Technical) {
            $task->via_technical = true;
        }

        $task->status = $to;
        $task->save();

        $this->writeAudit($task, $actor, $from, $to, $reason);
    }

    /**
     * Records an audited event that is not a state change, e.g. the
     * funding record overlay. from-state equals to-state.
     */
    public function recordEvent(Task $task, User $actor, string $reason): void
    {
        $this->writeAudit($task, $actor, $task->status, $task->status, $reason);
    }

    private function writeAudit(
        Task $task,
        ?User $actor,
        ?TaskStatus $from,
        TaskStatus $to,
        ?string $reason = null,
    ): void {
        AuditEntry::query()->create([
            'task_id' => $task->id,
            'actor_id' => $actor?->id,
            'actor_role' => $actor?->role,
            'company_id' => $task->company_id,
            'from_state' => $from,
            'to_state' => $to,
            'reason' => $reason,
            'via_technical' => $actor?->role === Role::Technical,
            'created_at' => now(),
        ]);
    }
}
