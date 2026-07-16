<?php

namespace App\Services;

use App\Enums\Priority;
use App\Enums\TaskStatus;
use App\Models\Task;
use Carbon\CarbonImmutable;
use Carbon\CarbonInterface;

/**
 * Daily recomputation of the approver-visible priority and the overdue
 * flag. Approvals happen Monday and Tuesday; priority is driven by how
 * many days remain until the next approval window, so it climbs as the
 * window approaches. The requester never sees it.
 */
class PriorityService
{
    /**
     * Live states carry the overdue flag; queue states carry priority.
     */
    private const QUEUE_STATES = [
        TaskStatus::Submitted,
        TaskStatus::PendingApproval,
        TaskStatus::Escalated,
    ];

    private const LIVE_STATES = [
        TaskStatus::Submitted,
        TaskStatus::PendingApproval,
        TaskStatus::Approved,
        TaskStatus::PendingReceipt,
        TaskStatus::Escalated,
    ];

    public function refresh(?CarbonInterface $today = null): int
    {
        $today = CarbonImmutable::parse($today ?? today());
        $updated = 0;

        Task::query()
            ->whereIn('status', self::QUEUE_STATES)
            ->chunkById(200, function ($tasks) use ($today, &$updated): void {
                foreach ($tasks as $task) {
                    $priority = $this->compute($task, $today);
                    if ($task->priority !== $priority) {
                        $task->priority = $priority;
                        $task->save();
                        $updated++;
                    }
                }
            });

        // Overdue is a boolean flag layered on live states, driven by
        // the due date; it is never a separate state.
        Task::query()
            ->whereIn('status', self::LIVE_STATES)
            ->whereNotNull('due_date')
            ->whereDate('due_date', '<', $today)
            ->where('overdue', false)
            ->update(['overdue' => true]);

        Task::query()
            ->where('overdue', true)
            ->where(function ($query) use ($today): void {
                $query->whereNull('due_date')
                    ->orWhereDate('due_date', '>=', $today)
                    ->orWhereNotIn('status', self::LIVE_STATES);
            })
            ->update(['overdue' => false]);

        return $updated;
    }

    /**
     * Days to the next Monday window, counting Monday through Wednesday
     * toward the following week because the current window has already
     * passed for new arrivals: Sun 1, Sat 2, Fri 3, Thu 4, Wed 5,
     * Tue 6, Mon 7. Bands: 1-2 High, 3-4 Medium, 5+ Low. A due date of
     * today is Urgent and overrides everything.
     */
    /**
     * Accepts either an App\Models\Task or a stdClass (from query results);
     * normalises the due_date to a CarbonImmutable or null before computing.
     */
    public function compute($task, CarbonInterface $today): Priority
    {
        $dueDate = null;
        if (isset($task->due_date) && $task->due_date !== null) {
            if ($task->due_date instanceof CarbonInterface) {
                $dueDate = $task->due_date;
            } else {
                // strings or other representations
                try {
                    $dueDate = CarbonImmutable::parse($task->due_date);
                } catch (\Exception $e) {
                    $dueDate = null;
                }
            }
        }

        if ($dueDate !== null && $dueDate->format('Y-m-d') === $today->format('Y-m-d')) {
            return Priority::Urgent;
        }

        $daysToWindow = match ($today->dayOfWeek) {
            CarbonInterface::SUNDAY => 1,
            CarbonInterface::SATURDAY => 2,
            CarbonInterface::FRIDAY => 3,
            CarbonInterface::THURSDAY => 4,
            CarbonInterface::WEDNESDAY => 5,
            CarbonInterface::TUESDAY => 6,
            CarbonInterface::MONDAY => 7,
        };

        return match (true) {
            $daysToWindow <= 2 => Priority::High,
            $daysToWindow <= 4 => Priority::Medium,
            default => Priority::Low,
        };
    }
}
