<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StorePettyCashRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Imprest issue fields: the recipient must hold an account, the
     * amount is integer ngwee, and the receipt-due date is optional.
     *
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'recipient_id' => ['required', 'integer', 'exists:users,id'],
            'amount_issued' => ['required', 'integer', 'min:1'],
            'purpose' => ['required', 'string', 'max:1000'],
            'receipt_due_date' => ['nullable', 'date', 'after:today'],
        ];
    }
}
