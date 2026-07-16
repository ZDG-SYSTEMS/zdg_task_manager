<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class PostponeTaskRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'due_date' => ['required', 'date', 'after:today'],
            'reason' => ['required', 'string', 'max:1000'],
        ];
    }
}
