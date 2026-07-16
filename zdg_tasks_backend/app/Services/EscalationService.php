<?php

namespace App\Services;

use App\Enums\NotificationEvent;
use App\Enums\TaskStatus;
use App\Models\Task;
use Carbon\CarbonImmutable;
use Carbon\CarbonInterface;

/**
 * Daily escalation of neglected approval-queue items to the Director
 * of Finance. An escalated task sits on the dof queue indefinitely
 * until the dof accepts or rejects it; escalation is never a silent
 * hard reject.
 */
class EscalationService
{
    /** Two full Mon/Tue priority cycles. */
    private const STALE_DAYS = 14;

    /** An urgent task overdue for two weeks. */
    private const OVERDUE_DAYS = 14;

    public function __construct(
        private readonly TaskStateMachine $stateMachine,
        private readonly TaskNotifier $notifier,
    ) {}

    public function escalateStale(?CarbonInterface $today = null): int
    {
        $today = CarbonImmutable::parse($today ?? today());
        $escalated = 0;

        Task::query()
            ->where('status', TaskStatus::PendingApproval)
            ->chunkById(200, function ($tasks) use ($today, &$escalated): void {
                foreach ($tasks as $task) {
                    // Ensure we have a Task model instance; when using chunkById with ->get(['id'])
                    // the items may be stdClass objects. Resolve to a Task model by id.
                    if (! $task instanceof Task) {
                        if (is_object($task) && property_exists($task, 'id')) {
                            $task = Task::find($task->id);
                        }
                    }

                    if (! $task instanceof Task) {
                        // Skip items we cannot resolve to a Task model
                        continue;
                    }

                    $reason = $this->escalationReason($task, $today);
                    if ($reason === null) {
                        continue;
                    }

                    // System-driven: no actor; the audit entry records
                    // why the task escalated.
                    $this->stateMachine->transition($task, TaskStatus::Escalated, null, $reason);
                    $this->notifier->notify($task, NotificationEvent::Escalated, $this->notifier->dof(), null, [
                        'reason' => $reason,
                    ]);
                    $escalated++;
                }
            });

        return $escalated;
    }

    private function escalationReason(Task $task, CarbonImmutable $today): ?string
    {
        // Rule 1: two full priority cycles with no action of any kind.
        $lastAction = $task->auditEntries()->max('created_at') ?? $task->created_at;
        $daysSinceAction = CarbonImmutable::parse($lastAction)->startOfDay()->diffInDays($today, false);

        if ($daysSinceAction >= self::STALE_DAYS) {
            return sprintf(
                'Escalated to the Director of Finance: no action for %d days (two full priority cycles).',
                (int) $daysSinceAction,
            );
        }

        // Rule 2: an urgent task overdue for two weeks.
        if ($task->due_date !== null) {
            $daysOverdue = CarbonImmutable::parse($task->due_date)->startOfDay()->diffInDays($today, false);
            if ($daysOverdue >= self::OVERDUE_DAYS) {
                return sprintf(
                    'Escalated to the Director of Finance: overdue for %d days.',
                    (int) $daysOverdue,
                );
            }
        }

        return null;
    }
}
