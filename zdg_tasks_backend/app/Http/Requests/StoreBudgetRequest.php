<?php

namespace App\Http\Requests;

use App\Enums\BudgetPeriodType;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreBudgetRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * A budget is scoped to a department within a company for a chosen
     * period. Amount is integer minor units (ngwee).
     *
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'company_id' => ['required', 'integer', 'exists:companies,id'],
            'department' => ['required', 'string', 'max:255'],
            'period_type' => ['required', Rule::enum(BudgetPeriodType::class)],
            'period_start' => ['required', 'date'],
            'period_end' => ['required', 'date', 'after:period_start'],
            'amount' => ['required', 'integer', 'min:1'],
        ];
    }
}
