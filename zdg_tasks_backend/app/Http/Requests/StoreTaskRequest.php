<?php

namespace App\Http\Requests;

use App\Enums\BeneficiaryType;
use App\Rules\MaxWords;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreTaskRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Creating always produces a draft, so only the title is mandatory;
     * submission enforces completeness. Amounts arrive as integer
     * ngwee.
     *
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string', new MaxWords(150)],
            'amount_requested' => ['nullable', 'integer', 'min:1'],
            'due_date' => ['nullable', 'date', 'after_or_equal:today'],
            'beneficiary_type' => ['nullable', Rule::enum(BeneficiaryType::class)],
            'beneficiary_name' => [
                'nullable', 'string', 'max:255',
                Rule::requiredIf($this->input('beneficiary_type') === BeneficiaryType::Other->value),
            ],
            'draft_reason' => ['nullable', 'string', 'max:255'],
        ];
    }
}
