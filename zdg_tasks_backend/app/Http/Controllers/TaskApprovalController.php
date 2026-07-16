<?php

namespace App\Http\Controllers;

use App\Enums\Role;
use App\Enums\UserStatus;
use App\Http\Requests\ApproveTaskRequest;
use App\Http\Requests\FundTaskRequest;
use App\Http\Requests\PostponeTaskRequest;
use App\Http\Requests\RejectTaskRequest;
use App\Models\Task;
use App\Models\User;
use App\Services\ApprovalService;
use Illuminate\Http\JsonResponse;

class TaskApprovalController extends Controller
{
    public function __construct(private readonly ApprovalService $approvals) {}

    public function approve(ApproveTaskRequest $request, Task $task): JsonResponse
    {
        $this->authorize('approve', $task);

        $data = $request->validated();

        if (($data['amount_approved'] ?? null) !== null
            && $data['amount_approved'] !== $task->amount_requested) {
            $this->authorize('editAmount', $task);
        }

        if (($data['assigned_funder_id'] ?? null) !== null) {
            // Approve-and-assign is a dof capability.
            $this->authorize('assign', $task);
        }

        $this->approvals->approve($task, $request->user(), $data);

        return response()->json(['task' => $task->refresh()]);
    }

    public function reject(RejectTaskRequest $request, Task $task): JsonResponse
    {
        $this->authorize('reject', $task);

        $this->approvals->reject($task, $request->user(), $request->validated('reason'));

        return response()->json(['task' => $task->refresh()]);
    }

    public function postpone(PostponeTaskRequest $request, Task $task): JsonResponse
    {
        $this->authorize('postpone', $task);

        $this->approvals->postpone(
            $task,
            $request->user(),
            $request->validated('due_date'),
            $request->validated('reason'),
        );

        return response()->json(['task' => $task->refresh()]);
    }

    /**
     * The company finance users the dof may assign this task to for
     * funding. Guarded by the assign ability, so only dof (and flagged
     * technical) can enumerate them.
     */
    public function assignableFunders(Task $task): JsonResponse
    {
        $this->authorize('assign', $task);

        return response()->json([
            'funders' => User::query()
                ->where('role', Role::CompanyFinance)
                ->where('company_id', $task->company_id)
                ->where('status', UserStatus::Active)
                ->orderBy('name')
                ->get(['id', 'code', 'name']),
        ]);
    }

    public function fund(FundTaskRequest $request, Task $task): JsonResponse
    {
        $this->authorize('fund', $task);

        $this->approvals->fund($task, $request->user(), $request->validated());

        return response()->json(['task' => $task->refresh()]);
    }
}
