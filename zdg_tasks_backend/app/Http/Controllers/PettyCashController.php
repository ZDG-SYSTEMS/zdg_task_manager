<?php

namespace App\Http\Controllers;

use App\Enums\TaskType;
use App\Http\Requests\ReturnBalanceRequest;
use App\Http\Requests\StorePettyCashRequest;
use App\Models\Receipt;
use App\Models\Task;
use App\Services\PettyCashService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PettyCashController extends Controller
{
    public function __construct(private readonly PettyCashService $pettyCash) {}

    /** Create and issue immediately; no approval step. */
    public function store(StorePettyCashRequest $request): JsonResponse
    {
        $this->authorize('create', [Task::class, TaskType::PettyCash]);

        $task = $this->pettyCash->create($request->user(), $request->validated());

        return response()->json([
            'task' => $task
                ->load(['recipient:id,code,name,position', 'company:id,code,name'])
                ->append('balance_remaining'),
        ], 201);
    }

    public function verifyReceipt(Request $request, Task $task, Receipt $receipt): JsonResponse
    {
        $this->authorize('verifyReceipts', $task);

        $verified = $this->pettyCash->verifyReceipt($task, $receipt, $request->user());

        return response()->json([
            'receipt' => $verified,
            'task' => $task->refresh()->append('balance_remaining'),
        ]);
    }

    public function returnBalance(ReturnBalanceRequest $request, Task $task): JsonResponse
    {
        $this->authorize('verifyReceipts', $task);

        $this->pettyCash->recordReturnedBalance($task, $request->user(), $request->validated('amount'));

        return response()->json([
            'task' => $task->refresh()->append('balance_remaining'),
        ]);
    }

    public function close(Request $request, Task $task): JsonResponse
    {
        $this->authorize('verifyReceipts', $task);

        $this->pettyCash->close($task, $request->user());

        return response()->json([
            'task' => $task->refresh()->append('balance_remaining'),
        ]);
    }
}
