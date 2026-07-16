<?php

namespace App\Models;

use App\Enums\Role;
use App\Enums\UserStatus;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

#[Fillable([
    'code', 'name', 'email', 'password', 'company_id', 'department',
    'branch', 'position', 'role', 'status',
])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'role' => Role::class,
            'status' => UserStatus::class,
        ];
    }

    /**
     * Next display code for a company: the company code plus a
     * zero-padded per-company sequence, e.g. ZDG001. Call inside a
     * transaction; the lock serialises concurrent registrations.
     * Padding grows past 999 members (ZDG1000), accepted because codes
     * are identifiers, not sort keys.
     */
    public static function nextCodeFor(Company $company): string
    {
        $latest = static::query()
            ->where('code', 'like', $company->code.'%')
            ->lockForUpdate()
            ->orderByRaw('LENGTH(code) DESC, code DESC')
            ->value('code');

        $next = $latest === null
            ? 1
            : ((int) substr($latest, strlen($company->code))) + 1;

        return $company->code.str_pad((string) $next, 3, '0', STR_PAD_LEFT);
    }

    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class);
    }

    public function createdTasks(): HasMany
    {
        return $this->hasMany(Task::class, 'created_by');
    }

    /** Petty cash tasks issued to this user. */
    public function receivedTasks(): HasMany
    {
        return $this->hasMany(Task::class, 'recipient_id');
    }

    public function appNotifications(): HasMany
    {
        return $this->hasMany(Notification::class);
    }

    public function deviceTokens(): HasMany
    {
        return $this->hasMany(DeviceToken::class);
    }
}
