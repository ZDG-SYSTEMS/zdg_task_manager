<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreAttachmentRequest;
use App\Models\Task;
use Illuminate\Http\JsonResponse;

class TaskAttachmentController extends Controller
{
    public function store(StoreAttachmentRequest $request, Task $task): JsonResponse
    {
        $this->authorize('attach', $task);

        $file = $request->file('file');
        $path = $file->store('attachments');

        $attachment = $task->attachments()->create([
            'kind' => $request->validated('kind'),
            'path' => $path,
            'original_name' => $file->getClientOriginalName(),
            'mime_type' => $file->getMimeType(),
            'size' => $file->getSize(),
            'uploaded_by' => $request->user()->id,
        ]);

        return response()->json(['attachment' => $attachment], 201);
    }
}
