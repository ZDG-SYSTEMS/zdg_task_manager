<?php

namespace App\Http\Controllers;

use App\Enums\Role;
use App\Enums\TaskStatus;
use App\Models\Budget;
use App\Models\Task;
use App\Services\BudgetService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function __construct(private readonly BudgetService $budgets) {}

    /**
     * Scoped dashboard: every figure is computed over the tasks the
     * viewer is allowed to see, so company scoping and the dept-head
     * own-tasks rule apply automatically.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $scope = fn () => Task::query()->visibleTo($user);

        $byStatus = $scope()
            ->selectRaw('status, count(*) as total')
            ->groupBy('status')
            ->pluck('total', 'status');

        $counts = [
            'total' => $byStatus->sum(),
            'pending' => $byStatus->only([
                TaskStatus::Submitted->value,
                TaskStatus::PendingApproval->value,
                TaskStatus::Escalated->value,
            ])->sum(),
            'in_progress' => $byStatus->only([
                TaskStatus::Approved->value,
                TaskStatus::PendingReceipt->value,
            ])->sum(),
            'assigned' => $scope()
                ->whereNotNull('assigned_funder_id')
                ->whereNotIn('status', [TaskStatus::Completed, TaskStatus::Rejected])
                ->count(),
            'overdue' => $scope()->where('overdue', true)->count(),
        ];

        // Overview series for graphs: the last six months of request
        // volume and cash released (funded_amount, never approved).
        $since = Carbon::now()->startOfMonth()->subMonths(5);

        $requestSeries = $scope()
            ->where('created_at', '>=', $since)
            ->selectRaw($this->monthExpression('created_at').' as month, count(*) as requests, coalesce(sum(amount_requested), 0) as requested_total')
            ->groupBy('month')
            ->orderBy('month')
            ->get();

        $fundedSeries = $scope()
            ->where('funded', true)
            ->where('funded_at', '>=', $since)
            ->selectRaw($this->monthExpression('funded_at').' as month, count(*) as funded_count, sum(funded_amount) as funded_total')
            ->groupBy('month')
            ->orderBy('month')
            ->get();

        return response()->json([
            'counts' => $counts,
            'by_status' => $byStatus,
            'monthly_requests' => $requestSeries,
            'monthly_funded' => $fundedSeries,
            'budgets' => $this->visibleBudgetPositions($request),
        ]);
    }

    /** Year-month grouping expression for the active database driver. */
    private function monthExpression(string $column): string
    {
        return match (DB::connection()->getDriverName()) {
            'sqlite' => "strftime('%Y-%m', {$column})",
            default => "DATE_FORMAT({$column}, '%Y-%m')",
        };
    }

    /**
     * Budget positions per CLAUDE.md: a set budget is visible to that
     * department's members and to finance; where none is set, no
     * budget UI appears (empty list).
     *
     * @return list<array<string, mixed>>
     */
    private function visibleBudgetPositions(Request $request): array
    {
        $user = $request->user();
        $today = Carbon::today();

        $query = Budget::query()
            ->with('company:id,code,name')
            ->whereDate('period_start', '<=', $today)
            ->whereDate('period_end', '>=', $today);

        $query = match ($user->role) {
            Role::Dof, Role::Technical => $query,
            Role::CompanyFinance => $query->where('company_id', $user->company_id),
            default => $query
                ->where('company_id', $user->company_id)
                ->where('department', $user->department),
        };

        return $query->get()
            ->map(fn (Budget $budget) => $this->budgets->position($budget))
            ->all();
    }
}
