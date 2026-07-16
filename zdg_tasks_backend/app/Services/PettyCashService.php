<?php

namespace App\Services;

use App\Enums\NotificationEvent;
use App\Enums\Role;
use App\Enums\TaskStatus;
use App\Enums\TaskType;
use App\Models\Receipt;
use App\Models\Task;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

/**
 * Imprest flow: money is issued first and reconciled afterwards. The
 * system tracks three figures continuously - amount issued, amount
 * accounted-for (sum of verified receipts), and balance remaining -
 * and the task completes only when finance verifies that receipts plus
 * returned balance fully account for the amount issued.
 */
class PettyCashService
{
    public function __construct(
        private readonly TaskStateMachine $stateMachine,
        private readonly TaskNotifier $notifier,
    ) {}

    /**
     * Create and issue immediately: finance is already the authority,
     * so there is no approval step. The task belongs to the
     * recipient's company; company_finance may only issue within its
     * own company.
     *
     * @param  array<string, mixed>  $data
     */
    public function create(User $actor, array $data): Task
    {
        $recipient = User::query()->findOrFail($data['recipient_id']);

        if ($actor->role === Role::CompanyFinance && $recipient->company_id !== $actor->company_id) {
            throw ValidationException::withMessages([
                'recipient_id' => 'Company finance may only issue petty cash within its own company.',
            ]);
        }

        $task = DB::transaction(function () use ($actor, $data, $recipient): Task {
            $task = new Task([
                'title' => 'Petty cash - '.$recipient->name,
                'description' => $data['purpose'],
                'amount_issued' => $data['amount_issued'],
                'amount_accounted' => 0,
                'receipt_due_date' => $data['receipt_due_date'] ?? null,
                'recipient_id' => $recipient->id,
            ]);
            $task->type = TaskType::PettyCash;
            $task->status = TaskStatus::PendingReceipt;
            $task->created_by = $actor->id;
            $task->company_id = $recipient->company_id;
            $task->via_technical = $actor->role === Role::Technical;
            $task->save();

            $this->stateMachine->recordCreation($task, $actor);

            return $task;
        });

        // The recipient must account for the money with receipts.
        $this->notifier->notify($task, NotificationEvent::ReceiptRequested, $recipient, $actor, [
            'due_date' => $task->receipt_due_date?->toDateString(),
        ]);

        return $task;
    }

    /**
     * Verify a receipt and recalculate the accounted figure. A
     * technical actor exercises the endpoint without effect: the
     * receipt stays unverified for the correct office, and the attempt
     * is tamper-flagged in the audit trail.
     */
    public function verifyReceipt(Task $task, Receipt $receipt, User $actor): Receipt
    {
        if ($receipt->verified) {
            throw ValidationException::withMessages([
                'receipt' => 'This receipt is already verified.',
            ]);
        }

        if ($actor->role === Role::Technical) {
            $this->stateMachine->recordEvent(
                $task,
                $actor,
                "Receipt {$receipt->id} verification exercised by technical; the receipt remains unverified for finance.",
            );

            return $receipt;
        }

        return DB::transaction(function () use ($task, $receipt, $actor): Receipt {
            $receipt->update([
                'verified' => true,
                'verified_by' => $actor->id,
                'verified_at' => now(),
            ]);

            $this->recalculateAccounted($task);

            $this->stateMachine->recordEvent(
                $task,
                $actor,
                "Receipt {$receipt->id} verified for {$receipt->amount} ngwee.",
            );

            return $receipt;
        });
    }

    /** Finance records physically returned leftover cash. */
    public function recordReturnedBalance(Task $task, User $actor, int $amount): Task
    {
        $this->assertOpenPettyCash($task);

        if ($actor->role === Role::Technical) {
            $this->stateMachine->recordEvent(
                $task,
                $actor,
                'Returned-balance recording exercised by technical; no balance was recorded.',
            );

            return $task;
        }

        return DB::transaction(function () use ($task, $actor, $amount): Task {
            $task->balance_returned = $amount;
            $task->save();

            $this->stateMachine->recordEvent(
                $task,
                $actor,
                "Returned balance recorded: {$amount} ngwee.",
            );

            return $task;
        });
    }

    /**
     * Close the imprest: only when verified receipts plus the returned
     * balance fully account for the amount issued.
     */
    public function close(Task $task, User $actor): Task
    {
        $this->assertOpenPettyCash($task);

        if ($actor->role === Role::Technical) {
            $this->stateMachine->recordEvent(
                $task,
                $actor,
                'Close exercised by technical; the task remains open for finance verification.',
            );

            return $task;
        }

        $accounted = $task->amount_accounted ?? 0;
        $returned = $task->balance_returned ?? 0;

        if ($accounted + $returned !== $task->amount_issued) {
            $outstanding = $task->amount_issued - $accounted - $returned;
            throw ValidationException::withMessages([
                'task' => "Receipts plus returned balance do not account for the amount issued: {$outstanding} ngwee outstanding.",
            ]);
        }

        $task = DB::transaction(function () use ($task, $actor, $accounted, $returned): Task {
            $this->stateMachine->transition(
                $task,
                TaskStatus::Completed,
                $actor,
                "Imprest reconciled: {$accounted} ngwee accounted plus {$returned} ngwee returned covers the amount issued.",
            );

            return $task;
        });

        $this->notifier->notify($task, NotificationEvent::Completed, $task->recipient, $actor);

        return $task;
    }

    private function recalculateAccounted(Task $task): void
    {
        if ($task->type !== TaskType::PettyCash) {
            return;
        }

        $task->amount_accounted = (int) $task->receipts()->where('verified', true)->sum('amount');
        $task->save();
    }

    private function assertOpenPettyCash(Task $task): void
    {
        if ($task->type !== TaskType::PettyCash) {
            throw ValidationException::withMessages([
                'task' => 'This action applies to petty cash tasks only.',
            ]);
        }

        if ($task->status === TaskStatus::Completed) {
            throw ValidationException::withMessages([
                'task' => 'This petty cash task is already reconciled and closed.',
            ]);
        }
    }
}
