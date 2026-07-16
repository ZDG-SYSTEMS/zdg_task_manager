<?php

namespace App\Http\Requests;

use App\Enums\Role;
use App\Enums\UserStatus;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Password;

class UpdateUserRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'email' => [
                'sometimes', 'string', 'email', 'max:255',
                Rule::unique('users', 'email')->ignore($this->route('user')),
            ],
            'password' => ['sometimes', Password::defaults()],
            'company_id' => ['sometimes', 'integer', 'exists:companies,id'],
            'department' => ['sometimes', 'string', 'max:255'],
            'branch' => ['sometimes', 'nullable', 'string', 'max:255'],
            'position' => ['sometimes', 'string', 'max:255'],
            'role' => ['sometimes', 'nullable', Rule::enum(Role::class)],
            'status' => ['sometimes', Rule::enum(UserStatus::class)],
        ];
    }
}
