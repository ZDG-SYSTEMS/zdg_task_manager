<?php

namespace App\Models;

use App\Enums\Role;
use App\Enums\TaskStatus;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use LogicException;

#[Fillable([
    'task_id', 'actor_id', 'actor_role', 'company_id', 'from_state',
    'to_state', 'reason', 'via_technical', 'created_at',
])]
class AuditEntry extends Model
{
    /** Immutable log: rows are inserted once and never touched again. */
    public const UPDATED_AT = null;

    protected static function booted(): void
    {
        static::updating(function (): never {
            throw new LogicException('Audit entries are immutable.');
        });
        static::deleting(function (): never {
            throw new LogicException('Audit entries are immutable.');
        });
    }

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'actor_role' => Role::class,
            'from_state' => TaskStatus::class,
            'to_state' => TaskStatus::class,
            'via_technical' => 'boolean',
            'created_at' => 'datetime',
        ];
    }

    public function task(): BelongsTo
    {
        return $this->belongsTo(Task::class);
    }

    public function actor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'actor_id');
    }

    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class);
    }
}
