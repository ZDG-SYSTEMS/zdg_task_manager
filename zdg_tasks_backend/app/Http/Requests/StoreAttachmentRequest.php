<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreAttachmentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Request-time attachments are quotations and invoices. PNG, JPEG,
     * PDF, Word; max 5 MB per file (CLAUDE.md). Receipts flow through
     * the receipts endpoints in later phases.
     *
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'file' => ['required', 'file', 'max:5120', 'mimes:png,jpg,jpeg,pdf,doc,docx'],
            'kind' => ['required', Rule::in(['quotation', 'invoice'])],
        ];
    }
}
