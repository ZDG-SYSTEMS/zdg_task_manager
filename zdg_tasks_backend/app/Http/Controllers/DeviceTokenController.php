<?php

namespace App\Http\Controllers;

use App\Models\DeviceToken;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DeviceTokenController extends Controller
{
    /** Register (or re-own) an FCM token for the signed-in device. */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'token' => ['required', 'string', 'max:512'],
            'platform' => ['nullable', 'string', 'max:16'],
        ]);

        // A token moving between accounts (shared device) re-attaches
        // to the current user.
        $token = DeviceToken::query()->updateOrCreate(
            ['token' => $data['token']],
            ['user_id' => $request->user()->id, 'platform' => $data['platform'] ?? null],
        );

        return response()->json(['device_token' => $token], 201);
    }

    public function destroy(Request $request): JsonResponse
    {
        $data = $request->validate(['token' => ['required', 'string']]);

        DeviceToken::query()
            ->where('token', $data['token'])
            ->where('user_id', $request->user()->id)
            ->delete();

        return response()->json(['message' => 'Device token removed.']);
    }
}
