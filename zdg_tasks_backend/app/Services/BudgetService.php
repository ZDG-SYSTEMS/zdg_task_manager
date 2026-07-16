<?php

namespace App\Services;

use App\Models\Budget;
use App\Models\Task;

/**
 * Budget position math. A budget is drawn down by funded amount
 * (aligned with the funding record): the sum of funded_amount across
 * tasks of the budget's company whose creator belongs to the budgeted
 * department, funded within the period.
 */
class BudgetService
{
    public function fundedToDate(Budget $budget): int
    {
        return (int) Task::query()
            ->where('company_id', $budget->company_id)
            ->where('funded', true)
            ->whereBetween('funded_at', [
                $budget->period_start->startOfDay(),
                $budget->period_end->endOfDay(),
            ])
            ->whereHas('creator', fn ($query) => $query->where('department', $budget->department))
            ->sum('funded_amount');
    }

    /** @return array<string, mixed> */
    public function position(Budget $budget): array
    {
        $funded = $this->fundedToDate($budget);

        return [
            'id' => $budget->id,
            'company' => $budget->company->only(['id', 'code', 'name']),
            'department' => $budget->department,
            'period_type' => $budget->period_type,
            'period_start' => $budget->period_start->toDateString(),
            'period_end' => $budget->period_end->toDateString(),
            'amount' => $budget->amount,
            'funded_to_date' => $funded,
            'remaining' => $budget->amount - $funded,
        ];
    }
}
