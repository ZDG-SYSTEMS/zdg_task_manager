<?php

namespace App\Http\Controllers;

use App\Enums\UserStatus;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Http\Requests\UpdateProfileRequest;
use App\Models\Company;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Self-registration: profile only, no role. The account stays
     * inactive and unable to log in until technical assigns a role.
     */
    public function register(RegisterRequest $request): JsonResponse
    {
        $data = $request->validated();
        $company = Company::query()->findOrFail($data['company_id']);

        $user = DB::transaction(fn (): User => User::query()->create([
            'code' => User::nextCodeFor($company),
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => $data['password'],
            'company_id' => $company->id,
            'department' => $data['department'],
            'branch' => $data['branch'] ?? null,
            'position' => $data['position'],
            'role' => null,
            'status' => UserStatus::Inactive,
        ]));

        return response()->json([
            'message' => 'Registration received. Your account will be activated once a role is assigned.',
            'user' => $user->load('company'),
        ], 201);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $user = User::query()->where('email', $request->validated('email'))->first();

        if ($user === null || ! Hash::check($request->validated('password'), $user->password)) {
            throw ValidationException::withMessages([
                'email' => 'The provided credentials are incorrect.',
            ]);
        }

        if ($user->role === null || $user->status !== UserStatus::Active) {
            return response()->json([
                'message' => 'Account pending activation. A role must be assigned before you can sign in.',
            ], 403);
        }

        $token = $user->createToken($request->validated('device_name') ?? 'api');

        return response()->json([
            'token' => $token->plainTextToken,
            'user' => $user->load('company'),
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logged out.']);
    }

    public function me(Request $request): JsonResponse
    {
        return response()->json(['user' => $request->user()->load('company')]);
    }

    public function updateMe(UpdateProfileRequest $request): JsonResponse
    {
        $user = $request->user();
        $user->fill($request->safe()->only(['name', 'email', 'password']));
        $user->save();

        return response()->json(['user' => $user->load('company')]);
    }
}
