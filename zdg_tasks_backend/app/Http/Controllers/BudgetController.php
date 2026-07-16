<?php

namespace App\Http\Controllers;

use App\Enums\Role;
use App\Http\Requests\StoreBudgetRequest;
use App\Models\Budget;
use App\Services\BudgetService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class BudgetController extends Controller
{
    public function __construct(private readonly BudgetService $budgets) {}

    /** Budgets the viewer may manage or report on, with positions. */
    public function index(Request $request): JsonResponse
    {
        $this->authorize('viewAny', Budget::class);

        $user = $request->user();

        $budgets = Budget::query()
            ->with('company:id,code,name')
            ->when(
                $user->role === Role::CompanyFinance,
                fn ($query) => $query->where('company_id', $user->company_id),
            )
            ->orderByDesc('period_start')
            ->get()
            ->map(fn (Budget $budget) => $this->budgets->position($budget));

        return response()->json(['budgets' => $budgets]);
    }

    public function store(StoreBudgetRequest $request): JsonResponse
    {
        $this->authorize('create', Budget::class);

        $user = $request->user();
        $data = $request->validated();

        if ($user->role === Role::CompanyFinance && (int) $data['company_id'] !== $user->company_id) {
            throw ValidationException::withMessages([
                'company_id' => 'Company finance may only set budgets for its own company.',
            ]);
        }

        $exists = Budget::query()
            ->where('company_id', $data['company_id'])
            ->where('department', $data['department'])
            ->whereDate('period_start', $data['period_start'])
            ->whereDate('period_end', $data['period_end'])
            ->exists();

        if ($exists) {
            throw ValidationException::withMessages([
                'department' => 'A budget for this department and period already exists.',
            ]);
        }

        $budget = Budget::query()->create([...$data, 'set_by' => $user->id]);

        return response()->json(['budget' => $this->budgets->position($budget)], 201);
    }

    public function update(StoreBudgetRequest $request, Budget $budget): JsonResponse
    {
        $this->authorize('update', $budget);

        $data = $request->validated();
        $user = $request->user();

        if ($user->role === Role::CompanyFinance && (int) $data['company_id'] !== $user->company_id) {
            throw ValidationException::withMessages([
                'company_id' => 'Company finance may only set budgets for its own company.',
            ]);
        }

        $budget->update($data);

        return response()->json(['budget' => $this->budgets->position($budget->refresh())]);
    }

    public function destroy(Budget $budget): JsonResponse
    {
        $this->authorize('delete', $budget);

        $budget->delete();

        return response()->json(['message' => 'Budget removed.']);
    }
}
