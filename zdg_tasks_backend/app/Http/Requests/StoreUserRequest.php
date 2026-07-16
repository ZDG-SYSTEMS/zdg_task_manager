<?php

namespace App\Http\Requests;

use App\Enums\Role;
use App\Enums\UserStatus;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Password;

class StoreUserRequest extends FormRequest
{
    public function authorize(): bool
    {
        // Policy check happens in the controller; requests only validate.
        return true;
    }

    /**
     * Technical creates accounts fully, including role and status.
     *
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', Password::defaults()],
            'company_id' => ['required', 'integer', 'exists:companies,id'],
            'department' => ['required', 'string', 'max:255'],
            'branch' => ['nullable', 'string', 'max:255'],
            'position' => ['required', 'string', 'max:255'],
            'role' => ['required', Rule::enum(Role::class)],
            'status' => ['sometimes', Rule::enum(UserStatus::class)],
        ];
    }
}
