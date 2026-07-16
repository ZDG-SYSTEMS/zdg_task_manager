<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    /** The signed-in user's own in-app notifications, newest first. */
    public function index(Request $request): JsonResponse
    {
        $notifications = Notification::query()
            ->where('user_id', $request->user()->id)
            ->with('task:id,title,type,status')
            ->when($request->boolean('unread'), fn ($q) => $q->whereNull('read_at'))
            ->latest()
            ->paginate(25);

        return response()->json($notifications);
    }

    public function markRead(Request $request, Notification $notification): JsonResponse
    {
        if ($notification->user_id !== $request->user()->id) {
            abort(403);
        }

        if ($notification->read_at === null) {
            $notification->update(['read_at' => now()]);
        }

        return response()->json(['notification' => $notification]);
    }
}
