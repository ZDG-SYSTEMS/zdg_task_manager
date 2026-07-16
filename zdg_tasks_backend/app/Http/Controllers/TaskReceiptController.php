<?php

namespace App\Http\Controllers;

use App\Enums\NotificationEvent;
use App\Enums\TaskStatus;
use App\Enums\TaskType;
use App\Http\Requests\StoreReceiptRequest;
use App\Models\Task;
use App\Services\TaskNotifier;
use App\Services\TaskStateMachine;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class TaskReceiptController extends Controller
{
    public function __construct(private readonly TaskStateMachine $stateMachine) {}

    /**
     * Upload proof of purchase. A standard request in pending_receipt
     * completes on upload. Petty cash receipts accumulate over time
     * and are reconciled by finance (Phase 5).
     */
    public function store(StoreReceiptRequest $request, Task $task): JsonResponse
    {
        $this->authorize('uploadReceipt', $task);

        if ($task->type === TaskType::Standard && $task->status !== TaskStatus::PendingReceipt) {
            throw ValidationException::withMessages([
                'task' => 'This request is not awaiting proof of purchase.',
            ]);
        }

        if ($task->type === TaskType::PettyCash && $task->status === TaskStatus::Completed) {
            throw ValidationException::withMessages([
                'task' => 'This petty cash task is already reconciled and closed.',
            ]);
        }

        $user = $request->user();
        $file = $request->file('file');

        $receipt = DB::transaction(function () use ($request, $task, $user, $file) {
            $attachment = $task->attachments()->create([
                'kind' => 'receipt',
                'path' => $file->store('attachments'),
                'original_name' => $file->getClientOriginalName(),
                'mime_type' => $file->getMimeType(),
                'size' => $file->getSize(),
                'uploaded_by' => $user->id,
            ]);

            $receipt = $task->receipts()->create([
                'attachment_id' => $attachment->id,
                'amount' => $request->validated('amount'),
                'verified' => false,
            ]);

            if ($task->type === TaskType::Standard) {
                $this->stateMachine->transition(
                    $task,
                    TaskStatus::Completed,
                    $user,
                    'Proof of purchase uploaded.',
                );
            }

            return $receipt;
        });

        if ($task->refresh()->status === TaskStatus::Completed) {
            // Chain end: the creator hears the request is resolved
            // (suppressed automatically when they uploaded it themselves).
            app(TaskNotifier::class)->notify($task, NotificationEvent::Completed, $task->creator, $user);
        }

        return response()->json([
            'receipt' => $receipt->load('attachment'),
            'task' => $task->refresh(),
        ], 201);
    }
}
