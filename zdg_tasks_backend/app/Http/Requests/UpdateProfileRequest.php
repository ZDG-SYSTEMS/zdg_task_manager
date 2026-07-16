<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Password;

class UpdateProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * The self-editable fields are name, email, and password only
     * (CLAUDE.md). Everything else is managed by technical. A password
     * change must prove the current password.
     *
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'email' => [
                'sometimes', 'string', 'email', 'max:255',
                Rule::unique('users', 'email')->ignore($this->user()->id),
            ],
            'password' => ['sometimes', 'confirmed', Password::defaults()],
            'current_password' => ['required_with:password', 'current_password'],
        ];
    }
}
