<?php

namespace App\Http\Controllers;

use App\Enums\UserStatus;
use App\Http\Requests\StoreUserRequest;
use App\Http\Requests\UpdateUserRequest;
use App\Models\Company;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class UserController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $this->authorize('viewAny', User::class);

        $users = User::query()
            ->with('company')
            ->when($request->query('company_id'), fn ($q, $id) => $q->where('company_id', $id))
            ->when($request->query('role'), fn ($q, $role) => $q->where('role', $role))
            ->when($request->query('status'), fn ($q, $status) => $q->where('status', $status))
            ->orderBy('code')
            ->paginate(25);

        return response()->json($users);
    }

    public function store(StoreUserRequest $request): JsonResponse
    {
        $this->authorize('create', User::class);

        $data = $request->validated();
        $company = Company::query()->findOrFail($data['company_id']);

        $user = DB::transaction(fn (): User => User::query()->create([
            ...$data,
            'code' => User::nextCodeFor($company),
            // Technical-created accounts are usable immediately unless
            // an explicit status says otherwise.
            'status' => $data['status'] ?? UserStatus::Active,
        ]));

        return response()->json(['user' => $user->load('company')], 201);
    }

    public function show(User $user): JsonResponse
    {
        $this->authorize('view', $user);

        return response()->json(['user' => $user->load('company')]);
    }

    public function update(UpdateUserRequest $request, User $user): JsonResponse
    {
        $this->authorize('update', $user);

        $data = $request->validated();

        // Assigning a role to a pending account activates it unless the
        // request states a status explicitly.
        $assigningRole = array_key_exists('role', $data)
            && $data['role'] !== null
            && $user->role === null;

        if ($assigningRole && ! array_key_exists('status', $data)) {
            $data['status'] = UserStatus::Active;
        }

        $user->fill($data);
        $user->save();

        return response()->json(['user' => $user->load('company')]);
    }

    public function destroy(Request $request, User $user): JsonResponse
    {
        $this->authorize('delete', $user);

        if ($request->user()->is($user)) {
            return response()->json(['message' => 'You cannot delete your own account.'], 422);
        }

        $user->tokens()->delete();
        $user->delete();

        return response()->json(['message' => 'User deleted.']);
    }
}
