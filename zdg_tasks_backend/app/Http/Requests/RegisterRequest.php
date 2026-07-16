<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Self-registration collects profile fields only. Role is never
     * chosen by the registrant; technical assigns it later, which
     * activates the account.
     *
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'confirmed', Password::defaults()],
            'company_id' => ['required', 'integer', 'exists:companies,id'],
            'department' => ['required', 'string', 'max:255'],
            'branch' => ['nullable', 'string', 'max:255'],
            'position' => ['required', 'string', 'max:255'],
        ];
    }
}
