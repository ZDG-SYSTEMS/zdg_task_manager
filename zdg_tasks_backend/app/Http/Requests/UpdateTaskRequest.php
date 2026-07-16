<?php

namespace App\Http\Requests;

use App\Enums\BeneficiaryType;
use App\Rules\MaxWords;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateTaskRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Draft editing: same field rules as creation, everything optional.
     *
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'title' => ['sometimes', 'string', 'max:255'],
            'description' => ['sometimes', 'nullable', 'string', new MaxWords(150)],
            'amount_requested' => ['sometimes', 'nullable', 'integer', 'min:1'],
            'due_date' => ['sometimes', 'nullable', 'date', 'after_or_equal:today'],
            'beneficiary_type' => ['sometimes', 'nullable', Rule::enum(BeneficiaryType::class)],
            'beneficiary_name' => ['sometimes', 'nullable', 'string', 'max:255'],
            'draft_reason' => ['sometimes', 'nullable', 'string', 'max:255'],
        ];
    }
}
