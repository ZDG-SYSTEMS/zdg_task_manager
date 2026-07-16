<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'task_id', 'attachment_id', 'amount', 'verified', 'verified_by',
    'verified_at',
])]
class Receipt extends Model
{
    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            // Integer minor units (ngwee).
            'amount' => 'integer',
            'verified' => 'boolean',
            'verified_at' => 'datetime',
        ];
    }

    public function task(): BelongsTo
    {
        return $this->belongsTo(Task::class);
    }

    public function attachment(): BelongsTo
    {
        return $this->belongsTo(Attachment::class);
    }

    public function verifier(): BelongsTo
    {
        return $this->belongsTo(User::class, 'verified_by');
    }
}
