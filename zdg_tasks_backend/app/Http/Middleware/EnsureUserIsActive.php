<?php

namespace App\Http\Middleware;

use App\Enums\UserStatus;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserIsActive
{
    /**
     * Tokens issued before a deactivation must stop working; every
     * authenticated request re-checks the account status.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if ($user !== null && $user->status !== UserStatus::Active) {
            return response()->json(['message' => 'Account is inactive.'], 403);
        }

        return $next($request);
    }
}
