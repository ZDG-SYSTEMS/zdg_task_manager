<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreReceiptRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Proof of purchase: same file constraints as other attachments,
     * plus the receipt amount in integer ngwee.
     *
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'file' => ['required', 'file', 'max:5120', 'mimes:png,jpg,jpeg,pdf,doc,docx'],
            'amount' => ['required', 'integer', 'min:1'],
        ];
    }
}
