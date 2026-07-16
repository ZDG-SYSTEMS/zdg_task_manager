<?php

namespace App\Services;

use App\Enums\NotificationEvent;
use App\Enums\Role;
use App\Enums\TaskStatus;
use App\Models\Task;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

/**
 * Approval-engine actions for standard requests. Every action runs
 * through the state machine so guards and audit entries always apply.
 *
 * Technical rule: a technical actor may exercise any action, but the
 * task is re-queued to pending_approval afterwards - a technical pass
 * is tamper-flagged and never a genuine authorization.
 */
class ApprovalService
{
    private const REQUEUE_REASON = 'Re-queued to the approval queue after a technical action.';

    public function __construct(
        private readonly TaskStateMachine $stateMachine,
        private readonly TaskNotifier $notifier,
    ) {}

    /**
     * Approve, optionally editing the amount (reason required) and
     * optionally assigning a funder (dof only; policy-checked by the
     * controller). Receipt-required decides the destination state.
     *
     * @param  array<string, mixed>  $data
     */
    public function approve(Task $task, User $actor, array $data): Task
    {
        $amountApproved = $data['amount_approved'] ?? $task->amount_requested;
        $editReason = $data['amount_edit_reason'] ?? null;

        if ($amountApproved !== $task->amount_requested && blank($editReason)) {
            throw ValidationException::withMessages([
                'amount_edit_reason' => 'A reason is required when the approved amount differs from the requested amount.',
            ]);
        }

        if ($amountApproved === $task->amount_requested) {
            $editReason = null;
        }

        $assignedFunderId = $data['assigned_funder_id'] ?? null;
        if ($assignedFunderId !== null) {
            $this->assertValidFunderAssignment($task, (int) $assignedFunderId);
        }

        $task = DB::transaction(function () use ($task, $actor, $data, $amountApproved, $editReason, $assignedFunderId): Task {
            $task->amount_approved = $amountApproved;
            $task->amount_edit_reason = $editReason;
            $task->receipt_required = $data['receipt_required'];
            if ($assignedFunderId !== null) {
                $task->assigned_funder_id = $assignedFunderId;
            }

            $this->stateMachine->transition($task, TaskStatus::Approved, $actor, $editReason);

            if ($actor->role === Role::Technical) {
                $this->stateMachine->transition($task, TaskStatus::PendingApproval, $actor, self::REQUEUE_REASON);

                return $task;
            }

            // Receipt required holds the task open for proof of
            // purchase; otherwise it completes on approval.
            $this->stateMachine->transition(
                $task,
                $data['receipt_required'] ? TaskStatus::PendingReceipt : TaskStatus::Completed,
                $actor,
            );

            return $task;
        });

        // The requester hears about the approval only once the chain
        // resolves, which is exactly now.
        $this->notifier->notify($task, NotificationEvent::Approved, $task->creator, $actor);

        if ($editReason !== null) {
            $this->notifier->notify($task, NotificationEvent::AmountEdited, $task->creator, $actor, [
                'reason' => $editReason,
            ]);
        }

        if ($task->receipt_required === true) {
            $this->notifier->notify($task, NotificationEvent::ReceiptRequested, $task->creator, $actor);
        }

        if ($task->assigned_funder_id !== null) {
            $this->notifier->notify($task, NotificationEvent::Assigned, $task->assignedFunder, $actor);
        }

        return $task;
    }

    public function reject(Task $task, User $actor, string $reason): Task
    {
        $task = DB::transaction(function () use ($task, $actor, $reason): Task {
            $this->stateMachine->transition($task, TaskStatus::Rejected, $actor, $reason);

            if ($actor->role === Role::Technical) {
                $this->stateMachine->transition($task, TaskStatus::PendingApproval, $actor, self::REQUEUE_REASON);
            }

            return $task;
        });

        $this->notifier->notify($task, NotificationEvent::Rejected, $task->creator, $actor, [
            'reason' => $reason,
        ]);

        return $task;
    }

    /**
     * Postpone through the transient postponed state: the same record
     * returns to pending_approval carrying the new due date. Calling
     * again later edits the postponed date.
     */
    public function postpone(Task $task, User $actor, string $newDueDate, string $reason): Task
    {
        $task = DB::transaction(function () use ($task, $actor, $newDueDate, $reason): Task {
            $this->stateMachine->transition($task, TaskStatus::Postponed, $actor, $reason);

            $task->due_date = $newDueDate;

            $this->stateMachine->transition(
                $task,
                TaskStatus::PendingApproval,
                $actor,
                "Returned to the approval queue with a new due date of {$newDueDate}.",
            );

            return $task;
        });

        // The requester is informed but has no action available.
        $this->notifier->notify($task, NotificationEvent::Postponed, $task->creator, $actor, [
            'reason' => $reason,
            'due_date' => $newDueDate,
        ]);

        return $task;
    }

    /**
     * Mark-as-funded: a data-only overlay recorded after approval. It
     * never moves state and never blocks completion; it is audited as
     * its own entry and drives cash-released reporting.
     *
     * @param  array<string, mixed>  $data
     */
    public function fund(Task $task, User $actor, array $data): Task
    {
        if ($task->funded) {
            throw ValidationException::withMessages([
                'funded' => 'This task already has a funding record.',
            ]);
        }

        if (! in_array($task->status, [TaskStatus::Approved, TaskStatus::PendingReceipt, TaskStatus::Completed], true)) {
            throw ValidationException::withMessages([
                'funded' => 'Only an approved task can be marked as funded.',
            ]);
        }

        return DB::transaction(function () use ($task, $actor, $data): Task {
            $task->funded = true;
            $task->funded_at = $data['funded_at'] ?? now();
            $task->funded_reference = $data['funded_reference'];
            $task->funded_amount = $data['funded_amount'];
            $task->funded_by = $actor->id;
            $task->save();

            $this->stateMachine->recordEvent(
                $task,
                $actor,
                "Funding recorded: reference {$task->funded_reference}, amount {$task->funded_amount} ngwee.",
            );

            return $task;
        });
    }

    /** Rejected requests may be edited and resubmitted by the creator. */
    public function resubmit(Task $task, User $actor): Task
    {
        $this->stateMachine->assertReadyForSubmission($task);

        $task = DB::transaction(function () use ($task, $actor): Task {
            $this->stateMachine->transition(
                $task,
                TaskStatus::PendingApproval,
                $actor,
                'Edited and resubmitted after rejection.',
            );

            return $task;
        });

        $this->notifier->notify(
            $task,
            NotificationEvent::SubmissionReceived,
            $this->notifier->financeOffice($task),
            $actor,
        );

        return $task;
    }

    private function assertValidFunderAssignment(Task $task, int $funderId): void
    {
        $funder = User::query()->find($funderId);

        if ($funder === null
            || $funder->role !== Role::CompanyFinance
            || $funder->company_id !== $task->company_id) {
            throw ValidationException::withMessages([
                'assigned_funder_id' => 'The assigned funder must be a company finance user of the task\'s company.',
            ]);
        }
    }
}
