<?php

namespace App\Http\Controllers;

use App\Enums\NotificationEvent;
use App\Enums\Role;
use App\Enums\TaskStatus;
use App\Enums\TaskType;
use App\Http\Requests\StoreTaskRequest;
use App\Http\Requests\UpdateTaskRequest;
use App\Models\Task;
use App\Models\User;
use App\Services\ApprovalService;
use App\Services\TaskNotifier;
use App\Services\TaskStateMachine;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TaskController extends Controller
{
    public function __construct(private readonly TaskStateMachine $stateMachine) {}

    /**
     * Visible tasks, newest first. company_finance and dof filter by
     * status=pending_approval to read their approval queues.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $isApprover = in_array($user->role, [Role::Technical, Role::Dof, Role::CompanyFinance], true);

        $tasks = Task::query()
            ->visibleTo($user)
            // Creator name, position, and branch feed the list's name
            // and location columns.
            ->with(['creator:id,code,name,position,branch', 'company:id,code,name'])
            ->when($request->query('status'), fn ($q, $status) => $q->where('status', $status))
            ->when($request->query('type'), fn ($q, $type) => $q->where('type', $type))
            ->when($request->query('company_id'), fn ($q, $id) => $q->where('company_id', $id))
            ->when($request->boolean('overdue'), fn ($q) => $q->where('overdue', true))
            // Priority is approver-visible only; the filter is ignored
            // for other roles so it cannot leak the hidden field.
            ->when(
                $isApprover && $request->query('priority'),
                fn ($q) => $q->where('priority', $request->query('priority')),
            )
            ->when($request->query('q'), function ($query, $term): void {
                $query->where(function ($inner) use ($term): void {
                    $like = '%'.str_replace(['%', '_'], ['\\%', '\\_'], $term).'%';
                    $inner->where('title', 'like', $like)
                        ->orWhere('description', 'like', $like)
                        ->orWhere('beneficiary_name', 'like', $like)
                        ->orWhereHas('creator', fn ($c) => $c->where('name', 'like', $like));
                });
            })
            ->latest()
            ->paginate(25);

        $tasks->getCollection()->transform(
            fn (Task $task): Task => $this->hidePriorityFromNonApprovers($task, $user)
        );

        return response()->json($tasks);
    }

    /** Creating a standard request always lands as a draft. */
    public function store(StoreTaskRequest $request): JsonResponse
    {
        $this->authorize('create', [Task::class, TaskType::Standard]);

        $user = $request->user();

        $task = DB::transaction(function () use ($request, $user): Task {
            $task = new Task($request->validated());
            $task->type = TaskType::Standard;
            $task->status = TaskStatus::Draft;
            $task->created_by = $user->id;
            $task->company_id = $user->company_id;
            $task->via_technical = $user->role === Role::Technical;
            $task->save();

            $this->stateMachine->recordCreation($task, $user);

            return $task;
        });

        // Creator name and position auto-attach for display.
        return response()->json([
            'task' => $task->load(['creator:id,code,name,position', 'company:id,code,name']),
        ], 201);
    }

    public function show(Request $request, Task $task): JsonResponse
    {
        $this->authorize('view', $task);

        $task->load(['creator:id,code,name,position', 'company:id,code,name', 'attachments']);

        if ($task->type === TaskType::PettyCash) {
            // The imprest figures track continuously: issued, accounted,
            // and remaining.
            $task->load('receipts.attachment')->append('balance_remaining');
        }

        return response()->json([
            'task' => $this->hidePriorityFromNonApprovers($task, $request->user()),
        ]);
    }

    /** Drafts remain editable until submission. */
    public function update(UpdateTaskRequest $request, Task $task): JsonResponse
    {
        $this->authorize('update', $task);

        if ($request->user()->role === Role::Technical) {
            $task->via_technical = true;
        }

        $task->fill($request->validated());
        $task->save();

        return response()->json([
            'task' => $task->load(['creator:id,code,name,position', 'company:id,code,name']),
        ]);
    }

    /**
     * Submit a complete draft: it enters the creator's company finance
     * queue as pending_approval and surfaces to the dof cross-company.
     */
    public function submit(Request $request, Task $task, TaskNotifier $notifier): JsonResponse
    {
        $this->authorize('submit', $task);

        $this->stateMachine->assertReadyForSubmission($task);

        $user = $request->user();

        DB::transaction(function () use ($task, $user): void {
            $this->stateMachine->transition($task, TaskStatus::Submitted, $user);
            // Routing to the approval queue is part of the same action.
            $this->stateMachine->transition($task, TaskStatus::PendingApproval, $user);
        });

        // The receiving office is told a submission arrived.
        $notifier->notify($task, NotificationEvent::SubmissionReceived, $notifier->financeOffice($task), $user);

        return response()->json([
            'message' => 'Request submitted to your company finance office.',
            'task' => $task->refresh()->load(['creator:id,code,name,position', 'company:id,code,name']),
        ]);
    }

    /**
     * A rejected request, once edited, returns to the approval queue.
     */
    public function resubmit(Request $request, Task $task, ApprovalService $approvals): JsonResponse
    {
        $this->authorize('resubmit', $task);

        $approvals->resubmit($task, $request->user());

        return response()->json([
            'message' => 'Request resubmitted to your company finance office.',
            'task' => $task->refresh()->load(['creator:id,code,name,position', 'company:id,code,name']),
        ]);
    }

    /**
     * Priority is approver-visible only: hidden from directors and
     * dept heads; reports handle their own field exposure.
     */
    private function hidePriorityFromNonApprovers(Task $task, User $user): Task
    {
        $approverRoles = [Role::Technical, Role::Dof, Role::CompanyFinance];

        if (! in_array($user->role, $approverRoles, true)) {
            $task->makeHidden('priority');
        }

        return $task;
    }
}
