<?php

namespace App\Services;

use App\Enums\Role;
use App\Enums\TaskStatus;
use App\Enums\TaskType;
use App\Models\AuditEntry;
use App\Models\Budget;
use App\Models\Company;
use App\Models\ReportFieldConfig;
use App\Models\Task;
use App\Models\User;
use Carbon\CarbonImmutable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Collection;

/**
 * The three report tiers. Every figure is computed over the viewer's
 * permitted companies (company_finance is forced to its own company)
 * and every tier's output is filtered through the report_field_configs
 * registry so accounts can finalise fields without a rebuild.
 *
 * Money figures are integer minor units (ngwee). Cash released is
 * always funded_amount, never approved amounts.
 */
class ReportService
{
    public function __construct(private readonly BudgetService $budgets) {}

    /** @return list<int> Company ids the viewer may report over. */
    public function scopeCompanyIds(User $user, ?int $companyId): array
    {
        if ($user->role === Role::CompanyFinance) {
            return [$user->company_id];
        }

        return $companyId !== null
            ? [$companyId]
            : Company::query()->pluck('id')->all();
    }

    /** @return array<string, mixed> */
    public function general(User $user, CarbonImmutable $start, CarbonImmutable $end, ?int $companyId): array
    {
        $companies = $this->scopeCompanyIds($user, $companyId);
        $metrics = $this->windowMetrics($companies, $start, $end);

        $scope = fn (): Builder => Task::query()->whereIn('company_id', $companies);

        $data = [
            'reporting_period' => $start->toDateString().' to '.$end->toDateString(),
            'company_scope' => Company::query()->whereIn('id', $companies)->orderBy('code')->pluck('code')->all(),
            'requests_raised' => $metrics['requests_raised'],
            'total_requested' => $metrics['total_requested'],
            'total_approved' => $metrics['total_approved'],
            'total_funded' => $metrics['total_funded'],
            'rejected_count' => $metrics['rejected_count'],
            'rejected_value' => $metrics['rejected_value'],
            'completed_count' => $metrics['completed_count'],
            'completed_value' => $metrics['completed_value'],
            'pending_count' => $scope()->whereIn('status', [
                TaskStatus::Submitted, TaskStatus::PendingApproval, TaskStatus::Escalated,
            ])->count(),
            'in_progress_count' => $scope()->whereIn('status', [
                TaskStatus::Approved, TaskStatus::PendingReceipt,
            ])->count(),
            'overdue_count' => $scope()->where('overdue', true)->count(),
            'petty_cash_issued_count' => $metrics['petty_issued_count'],
            'petty_cash_issued_value' => $metrics['petty_issued_value'],
            'petty_cash_accounted' => $metrics['petty_accounted'],
            'petty_cash_outstanding' => $metrics['petty_outstanding'],
            'budget_vs_funded' => $this->budgetPositions($companies, $start, $end),
            'approval_rate' => $this->rate($metrics['approved_count'], $metrics['approved_count'] + $metrics['rejected_count']),
            'average_approval_turnaround_days' => $this->averageTurnaround($companies, $start, $end),
        ];

        return $this->filterFields($data, 'general');
    }

    /** @return array<string, mixed> */
    public function comparison(User $user, CarbonImmutable $start, CarbonImmutable $end, ?int $companyId): array
    {
        $companies = $this->scopeCompanyIds($user, $companyId);

        $lengthDays = (int) $start->diffInDays($end);
        $previousStart = $start->subDays($lengthDays + 1);
        $previousEnd = $start->subDay();

        $current = $this->windowMetrics($companies, $start, $end);
        $previous = $this->windowMetrics($companies, $previousStart, $previousEnd);

        $compare = fn (string $key): array => [
            'current' => $current[$key],
            'previous' => $previous[$key],
            'variance' => $current[$key] - $previous[$key],
            'variance_percent' => $previous[$key] > 0
                ? round(($current[$key] - $previous[$key]) / $previous[$key] * 100, 1)
                : null,
        ];

        $fundedByCompany = Task::query()
            ->whereIn('company_id', $companies)
            ->where('funded', true)
            ->whereBetween('funded_at', [$start->startOfDay(), $end->endOfDay()])
            ->join('companies', 'companies.id', '=', 'tasks.company_id')
            ->selectRaw('companies.code as company, sum(tasks.funded_amount) as funded_total')
            ->groupBy('companies.code')
            ->get();

        $fundedByDepartment = Task::query()
            ->whereIn('tasks.company_id', $companies)
            ->where('funded', true)
            ->whereBetween('funded_at', [$start->startOfDay(), $end->endOfDay()])
            ->join('users', 'users.id', '=', 'tasks.created_by')
            ->selectRaw('users.department as department, sum(tasks.funded_amount) as funded_total')
            ->groupBy('users.department')
            ->get();

        $grandTotal = max(1, (int) $fundedByCompany->sum('funded_total'));

        $data = [
            'periods' => [
                'current' => $start->toDateString().' to '.$end->toDateString(),
                'previous' => $previousStart->toDateString().' to '.$previousEnd->toDateString(),
            ],
            'company_scope' => Company::query()->whereIn('id', $companies)->orderBy('code')->pluck('code')->all(),
            'requested_vs_approved_vs_funded' => [
                'requested' => $compare('total_requested'),
                'approved' => $compare('total_approved'),
                'funded' => $compare('total_funded'),
                'accounted' => $compare('petty_accounted'),
            ],
            'budget_vs_funded_by_department' => collect($this->budgetPositions($companies, $start, $end))
                ->groupBy('department')
                ->map(fn ($group) => $group->values())
                ->toArray(),
            'cost_distribution' => [
                'by_company' => $fundedByCompany->map(fn ($row) => [
                    'company' => $row->company,
                    'funded_total' => (int) $row->funded_total,
                    'share_percent' => round((int) $row->funded_total / $grandTotal * 100, 1),
                ]),
                'by_department' => $fundedByDepartment->map(fn ($row) => [
                    'department' => $row->department,
                    'funded_total' => (int) $row->funded_total,
                    'share_percent' => round((int) $row->funded_total / $grandTotal * 100, 1),
                ]),
            ],
            'rejection_rate_trend' => [
                'current' => $this->rate($current['rejected_count'], $current['approved_count'] + $current['rejected_count']),
                'previous' => $this->rate($previous['rejected_count'], $previous['approved_count'] + $previous['rejected_count']),
            ],
            'overdue_rate_trend' => [
                'current' => $current['overdue_rate'],
                'previous' => $previous['overdue_rate'],
            ],
            'outstanding_imprest_trend' => [
                'current' => $current['petty_outstanding'],
                'previous' => $previous['petty_outstanding'],
            ],
        ];

        return $this->filterFields($data, 'comparison', ['periods', 'company_scope']);
    }

    /** @return array<string, mixed> */
    public function inDepth(User $user, CarbonImmutable $start, CarbonImmutable $end, ?int $companyId): array
    {
        $companies = $this->scopeCompanyIds($user, $companyId);

        $tasks = Task::query()
            ->whereIn('company_id', $companies)
            ->whereBetween('created_at', [$start->startOfDay(), $end->endOfDay()])
            ->with([
                'creator:id,code,name,position,department,branch',
                'company:id,code,name',
                'recipient:id,code,name',
                'assignedFunder:id,code,name',
                'funder:id,code,name',
                'auditEntries' => fn ($q) => $q->orderBy('id')->with('actor:id,code,name'),
                'attachments:id,attachable_id,attachable_type,kind',
            ])
            ->orderByDesc('created_at')
            ->get();

        $rows = $tasks->map(fn (Task $task): array => $this->filterFields($this->taskRow($task), 'in_depth'))->all();

        return [
            'reporting_period' => $start->toDateString().' to '.$end->toDateString(),
            'company_scope' => Company::query()->whereIn('id', $companies)->orderBy('code')->pluck('code')->all(),
            'tasks' => $rows,
            'exceptions' => $this->exceptions($companies),
        ];
    }

    /** @return array<string, mixed> Shared per-window figures. */
    private function windowMetrics(array $companies, CarbonImmutable $start, CarbonImmutable $end): array
    {
        $window = [$start->startOfDay(), $end->endOfDay()];

        $standardCreated = Task::query()
            ->whereIn('company_id', $companies)
            ->where('type', TaskType::Standard)
            ->whereBetween('created_at', $window);

        $approvedTaskIds = $this->transitionTaskIds($companies, TaskStatus::Approved, $window);
        $rejectedTaskIds = $this->transitionTaskIds($companies, TaskStatus::Rejected, $window);
        $completedTaskIds = $this->transitionTaskIds($companies, TaskStatus::Completed, $window);

        $completedTasks = Task::query()->whereIn('id', $completedTaskIds)->get();

        $pettyIssued = Task::query()
            ->whereIn('company_id', $companies)
            ->where('type', TaskType::PettyCash)
            ->whereBetween('created_at', $window)
            ->get();

        $createdInWindow = Task::query()
            ->whereIn('company_id', $companies)
            ->whereBetween('created_at', $window);

        return [
            'requests_raised' => (clone $standardCreated)->count(),
            'total_requested' => (int) (clone $standardCreated)->sum('amount_requested'),
            'approved_count' => count($approvedTaskIds),
            'total_approved' => (int) Task::query()->whereIn('id', $approvedTaskIds)->sum('amount_approved'),
            'rejected_count' => count($rejectedTaskIds),
            'rejected_value' => (int) Task::query()->whereIn('id', $rejectedTaskIds)->sum('amount_requested'),
            'completed_count' => count($completedTaskIds),
            'completed_value' => (int) $completedTasks->sum(
                fn (Task $task) => $task->funded_amount ?? $task->amount_approved ?? $task->amount_issued ?? 0,
            ),
            'total_funded' => (int) Task::query()
                ->whereIn('company_id', $companies)
                ->where('funded', true)
                ->whereBetween('funded_at', $window)
                ->sum('funded_amount'),
            'petty_issued_count' => $pettyIssued->count(),
            'petty_issued_value' => (int) $pettyIssued->sum('amount_issued'),
            'petty_accounted' => (int) $pettyIssued->sum('amount_accounted'),
            'petty_outstanding' => (int) $pettyIssued->sum(fn (Task $task) => max(
                0,
                ($task->amount_issued ?? 0) - ($task->amount_accounted ?? 0) - ($task->balance_returned ?? 0),
            )),
            'overdue_rate' => $this->rate(
                (clone $createdInWindow)->where('overdue', true)->count(),
                (clone $createdInWindow)->count(),
            ) ?? 0.0,
        ];
    }

    /** @return list<int> Distinct tasks that entered a state in the window (genuine actions only). */
    private function transitionTaskIds(array $companies, TaskStatus $state, array $window): array
    {
        return AuditEntry::query()
            ->whereIn('company_id', $companies)
            ->where('to_state', $state)
            ->where('via_technical', false)
            ->whereBetween('created_at', $window)
            ->distinct()
            ->pluck('task_id')
            ->all();
    }

    /** @return list<array<string, mixed>> */
    private function budgetPositions(array $companies, CarbonImmutable $start, CarbonImmutable $end): array
    {
        return Budget::query()
            ->with('company:id,code,name')
            ->whereIn('company_id', $companies)
            ->whereDate('period_start', '<=', $end)
            ->whereDate('period_end', '>=', $start)
            ->get()
            ->map(fn (Budget $budget) => $this->budgets->position($budget))
            ->all();
    }

    private function averageTurnaround(array $companies, CarbonImmutable $start, CarbonImmutable $end): ?float
    {
        $approvals = AuditEntry::query()
            ->whereIn('company_id', $companies)
            ->where('to_state', TaskStatus::Approved)
            ->where('via_technical', false)
            ->whereBetween('created_at', [$start->startOfDay(), $end->endOfDay()])
            ->get()
            ->groupBy('task_id')
            ->map(fn (Collection $entries) => $entries->first());

        if ($approvals->isEmpty()) {
            return null;
        }

        $submissions = AuditEntry::query()
            ->whereIn('task_id', $approvals->keys())
            ->where('to_state', TaskStatus::PendingApproval)
            ->orderBy('id')
            ->get()
            ->groupBy('task_id')
            ->map(fn (Collection $entries) => $entries->first());

        $days = $approvals
            ->map(function (AuditEntry $approval) use ($submissions): ?float {
                $submission = $submissions->get($approval->task_id);

                return $submission === null
                    ? null
                    : round($submission->created_at->diffInDays($approval->created_at, false), 1);
            })
            ->filter(fn (?float $value) => $value !== null && $value >= 0);

        return $days->isEmpty() ? null : round($days->avg(), 1);
    }

    /** @return array<string, mixed> One in-depth row; filtered by field config upstream. */
    private function taskRow(Task $task): array
    {
        $approval = $task->auditEntries->first(
            fn (AuditEntry $entry) => $entry->to_state === TaskStatus::Approved && ! $entry->via_technical,
        );
        $completion = $task->auditEntries->first(fn (AuditEntry $entry) => $entry->to_state === TaskStatus::Completed);

        $outstanding = $task->type === TaskType::PettyCash
            ? max(0, ($task->amount_issued ?? 0) - ($task->amount_accounted ?? 0) - ($task->balance_returned ?? 0))
            : null;

        return [
            'task_id' => $task->id,
            'type' => $task->type,
            'title' => $task->title,
            'company' => $task->company->code,
            'department' => $task->creator->department,
            'branch' => $task->creator->branch,
            'requester' => [
                'name' => $task->creator->name,
                'position' => $task->creator->position,
                'id' => $task->creator->code,
            ],
            'beneficiary' => $task->type === TaskType::PettyCash
                ? $task->recipient?->name
                : ($task->beneficiary_type?->value === 'other' ? $task->beneficiary_name : $task->creator->name),
            'dates' => [
                'created' => $task->created_at?->toDateString(),
                'due' => $task->due_date?->toDateString(),
                'approved' => $approval?->created_at->toDateString(),
                'funded' => $task->funded_at?->toDateString(),
                'completed' => $completion?->created_at->toDateString(),
            ],
            'priority_at_resolution' => $task->priority,
            'amount_requested' => $task->amount_requested,
            'amount_approved' => $task->amount_approved,
            'edit_delta_and_reason' => $task->amount_edit_reason === null ? null : [
                'delta' => ($task->amount_approved ?? 0) - ($task->amount_requested ?? 0),
                'reason' => $task->amount_edit_reason,
            ],
            'funded_amount' => $task->funded_amount,
            'funded_reference' => $task->funded_reference,
            'funded_by' => $task->funder?->name,
            'receipt_required' => $task->receipt_required,
            'amount_accounted' => $task->amount_accounted,
            'balance_returned' => $task->balance_returned,
            'balance_outstanding' => $outstanding,
            'approver' => $approval === null ? null : [
                'name' => $approval->actor?->name,
                'role' => $approval->actor_role,
            ],
            'assigned_funder' => $task->assignedFunder?->name,
            'via_technical' => $task->via_technical,
            'status' => $task->status,
            'audit_trail' => $task->auditEntries->map(fn (AuditEntry $entry) => [
                'actor' => $entry->actor?->name,
                'actor_role' => $entry->actor_role,
                'from' => $entry->from_state,
                'to' => $entry->to_state,
                'reason' => $entry->reason,
                'via_technical' => $entry->via_technical,
                'at' => $entry->created_at->toIso8601String(),
            ])->all(),
            'attachment_counts' => $task->attachments->countBy(fn ($attachment) => $attachment->kind->value),
            'per_state_aging' => $this->perStateAging($task),
        ];
    }

    /** @return array<string, float> Days spent in each state so far. */
    private function perStateAging(Task $task): array
    {
        $aging = [];
        $entries = $task->auditEntries->values();

        foreach ($entries as $index => $entry) {
            $stateEnd = $entries->get($index + 1)?->created_at ?? now();
            $state = $entry->to_state->value;
            $aging[$state] = round(($aging[$state] ?? 0) + $entry->created_at->diffInDays($stateEnd, false), 1);
        }

        return $aging;
    }

    /** @return array<string, mixed> The exception sets for the in-depth tier. */
    private function exceptions(array $companies): array
    {
        $scope = fn (): Builder => Task::query()->whereIn('company_id', $companies);

        $openPetty = $scope()
            ->where('type', TaskType::PettyCash)
            ->where('status', '!=', TaskStatus::Completed)
            ->get()
            ->map(fn (Task $task) => [
                'task_id' => $task->id,
                'title' => $task->title,
                'outstanding' => max(0, ($task->amount_issued ?? 0) - ($task->amount_accounted ?? 0) - ($task->balance_returned ?? 0)),
                'age_days' => (int) $task->created_at->diffInDays(now()),
            ])
            ->filter(fn (array $row) => $row['outstanding'] > 0)
            ->values();

        $bucket = fn (int $days): string => match (true) {
            $days <= 30 => '0-30',
            $days <= 60 => '31-60',
            $days <= 90 => '61-90',
            default => '90+',
        };

        return [
            'outstanding_imprest_aging' => $openPetty->groupBy(fn (array $row) => $bucket($row['age_days']))->toArray(),
            'overdue_and_escalated' => $scope()
                ->where(fn ($q) => $q->where('overdue', true)->orWhere('status', TaskStatus::Escalated))
                ->get(['id', 'title', 'status', 'overdue', 'due_date'])
                ->toArray(),
            'edited_amounts' => $scope()
                ->whereNotNull('amount_edit_reason')
                ->get()
                ->map(fn (Task $task) => [
                    'task_id' => $task->id,
                    'title' => $task->title,
                    'requested' => $task->amount_requested,
                    'approved' => $task->amount_approved,
                    'delta' => ($task->amount_approved ?? 0) - ($task->amount_requested ?? 0),
                    'reason' => $task->amount_edit_reason,
                ])->all(),
            'approved_not_funded' => $scope()
                ->whereIn('status', [TaskStatus::Approved, TaskStatus::PendingReceipt, TaskStatus::Completed])
                ->where('funded', false)
                ->whereNotNull('amount_approved')
                ->get(['id', 'title', 'status', 'amount_approved'])
                ->toArray(),
            'rejections' => $scope()
                ->where('status', TaskStatus::Rejected)
                ->with(['auditEntries' => fn ($q) => $q->where('to_state', TaskStatus::Rejected)->orderByDesc('id')])
                ->get()
                ->map(fn (Task $task) => [
                    'task_id' => $task->id,
                    'title' => $task->title,
                    'reason' => $task->auditEntries->first()?->reason,
                ])->all(),
            'technical_flagged' => $scope()
                ->where('via_technical', true)
                ->get(['id', 'title', 'status'])
                ->toArray(),
            'receipts_missing_past_due' => $scope()
                ->where('type', TaskType::PettyCash)
                ->where('status', '!=', TaskStatus::Completed)
                ->whereNotNull('receipt_due_date')
                ->whereDate('receipt_due_date', '<', today())
                ->get()
                ->map(fn (Task $task) => [
                    'task_id' => $task->id,
                    'title' => $task->title,
                    'receipt_due_date' => $task->receipt_due_date->toDateString(),
                    'outstanding' => max(0, ($task->amount_issued ?? 0) - ($task->amount_accounted ?? 0) - ($task->balance_returned ?? 0)),
                ])->all(),
        ];
    }

    private function rate(int $part, int $whole): ?float
    {
        return $whole > 0 ? round($part / $whole * 100, 1) : null;
    }

    /**
     * Keep only registry-enabled fields for a tier, in registry order.
     * Always-on structural keys can be exempted.
     *
     * @param  array<string, mixed>  $data
     * @param  list<string>  $alwaysKeep
     * @return array<string, mixed>
     */
    private function filterFields(array $data, string $tier, array $alwaysKeep = []): array
    {
        $enabled = ReportFieldConfig::query()
            ->where('report_tier', $tier)
            ->where('enabled', true)
            ->orderBy('sort_order')
            ->pluck('field_key')
            ->all();

        $filtered = [];
        foreach ([...$alwaysKeep, ...$enabled] as $key) {
            if (array_key_exists($key, $data)) {
                $filtered[$key] = $data[$key];
            }
        }

        return $filtered;
    }
}
