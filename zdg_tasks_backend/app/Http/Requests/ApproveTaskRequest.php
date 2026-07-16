<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ApproveTaskRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * The approver may edit the amount (integer ngwee); the edit-reason
     * requirement is enforced by the service, which knows the requested
     * amount. Receipt-required is the mandatory radial.
     *
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'amount_approved' => ['nullable', 'integer', 'min:1'],
            'amount_edit_reason' => ['nullable', 'string', 'max:1000'],
            'receipt_required' => ['required', 'boolean'],
            'assigned_funder_id' => ['nullable', 'integer', 'exists:users,id'],
        ];
    }
}
