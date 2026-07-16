<?php

namespace App\Models;

use App\Enums\BudgetPeriodType;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'company_id', 'department', 'period_type', 'period_start',
    'period_end', 'amount', 'set_by',
])]
class Budget extends Model
{
    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'period_type' => BudgetPeriodType::class,
            'period_start' => 'date',
            'period_end' => 'date',
            // Integer minor units (ngwee). Drawn down by funded amounts.
            'amount' => 'integer',
        ];
    }

    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class);
    }

    public function setBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'set_by');
    }
}
