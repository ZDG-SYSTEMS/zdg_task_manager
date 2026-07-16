<?php

namespace App\Models;

use App\Enums\BeneficiaryType;
use App\Enums\Priority;
use App\Enums\Role;
use App\Enums\TaskStatus;
use App\Enums\TaskType;
use Database\Factories\TaskFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\MorphMany;

#[Fillable([
    'type', 'title', 'description', 'draft_reason', 'created_by', 'company_id',
    'amount_requested', 'amount_approved', 'amount_edit_reason', 'currency',
    'due_date', 'beneficiary_type', 'beneficiary_name', 'receipt_required',
    'priority', 'status', 'overdue', 'via_technical', 'assigned_funder_id',
    'funded', 'funded_at', 'funded_reference', 'funded_amount', 'funded_by',
    'amount_issued', 'amount_accounted', 'balance_returned',
    'receipt_due_date', 'recipient_id',
])]
class Task extends Model
{
    /** @use HasFactory<TaskFactory> */
    use HasFactory;

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'type' => TaskType::class,
            'status' => TaskStatus::class,
            'priority' => Priority::class,
            'beneficiary_type' => BeneficiaryType::class,
            // Money is integer minor units (ngwee); never floats.
            'amount_requested' => 'integer',
            'amount_approved' => 'integer',
            'funded_amount' => 'integer',
            'amount_issued' => 'integer',
            'amount_accounted' => 'integer',
            'balance_returned' => 'integer',
            'due_date' => 'date',
            'receipt_due_date' => 'date',
            'funded_at' => 'datetime',
            'receipt_required' => 'boolean',
            'overdue' => 'boolean',
            'via_technical' => 'boolean',
            'funded' => 'boolean',
        ];
    }

    /**
     * The third imprest figure: what the recipient still has to account
     * for. Null for standard requests.
     */
    protected function balanceRemaining(): Attribute
    {
        return Attribute::get(function (): ?int {
            if ($this->type !== TaskType::PettyCash || $this->amount_issued === null) {
                return null;
            }

            return $this->amount_issued
                - ($this->amount_accounted ?? 0)
                - ($this->balance_returned ?? 0);
        });
    }

    /**
     * The tasks this user may see. Mirrors TaskPolicy::view for list
     * queries: technical, dof, and auditor see all companies;
     * director and company_finance their own company; dept_head only
     * tasks they created or received.
     */
    public function scopeVisibleTo(Builder $query, User $user): Builder
    {
        return match ($user->role) {
            Role::Technical, Role::Dof, Role::Auditor => $query,
            Role::Director, Role::CompanyFinance => $query->where('company_id', $user->company_id),
            default => $query->where(function (Builder $inner) use ($user): void {
                $inner->where('created_by', $user->id)
                    ->orWhere('recipient_id', $user->id);
            }),
        };
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class);
    }

    public function assignedFunder(): BelongsTo
    {
        return $this->belongsTo(User::class, 'assigned_funder_id');
    }

    public function funder(): BelongsTo
    {
        return $this->belongsTo(User::class, 'funded_by');
    }

    /** Petty cash recipient; must hold an account. */
    public function recipient(): BelongsTo
    {
        return $this->belongsTo(User::class, 'recipient_id');
    }

    public function attachments(): MorphMany
    {
        return $this->morphMany(Attachment::class, 'attachable');
    }

    public function receipts(): HasMany
    {
        return $this->hasMany(Receipt::class);
    }

    public function auditEntries(): HasMany
    {
        return $this->hasMany(AuditEntry::class);
    }

    public function notifications(): HasMany
    {
        return $this->hasMany(Notification::class);
    }
}
