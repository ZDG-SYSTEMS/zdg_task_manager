<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['report_tier', 'field_key', 'label', 'enabled', 'sort_order'])]
class ReportFieldConfig extends Model
{
    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'enabled' => 'boolean',
            'sort_order' => 'integer',
        ];
    }
}
