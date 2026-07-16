<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class FundTaskRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * The funding record fields: amount in integer ngwee, an external
     * payment reference, and optionally when the release happened.
     *
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'funded_amount' => ['required', 'integer', 'min:1'],
            'funded_reference' => ['required', 'string', 'max:255'],
            'funded_at' => ['nullable', 'date', 'before_or_equal:now'],
        ];
    }
}
