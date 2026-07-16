<?php

namespace App\Models;

use App\Enums\AttachmentKind;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphTo;

#[Fillable([
    'attachable_type', 'attachable_id', 'kind', 'path', 'original_name',
    'mime_type', 'size', 'uploaded_by',
])]
class Attachment extends Model
{
    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'kind' => AttachmentKind::class,
            'size' => 'integer',
        ];
    }

    public function attachable(): MorphTo
    {
        return $this->morphTo();
    }

    public function uploader(): BelongsTo
    {
        return $this->belongsTo(User::class, 'uploaded_by');
    }
}
