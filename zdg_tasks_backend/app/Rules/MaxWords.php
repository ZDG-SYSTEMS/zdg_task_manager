<?php

namespace App\Rules;

use Closure;
use Illuminate\Contracts\Validation\ValidationRule;

class MaxWords implements ValidationRule
{
    public function __construct(private readonly int $limit) {}

    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        if (! is_string($value)) {
            return;
        }

        $words = preg_split('/\s+/', trim($value), -1, PREG_SPLIT_NO_EMPTY);

        if (count($words) > $this->limit) {
            $fail("The {$attribute} may not exceed {$this->limit} words.");
        }
    }
}
