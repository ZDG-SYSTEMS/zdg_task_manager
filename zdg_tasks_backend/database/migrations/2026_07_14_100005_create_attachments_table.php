<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('attachments', function (Blueprint $table) {
            $table->id();
            // Polymorphic so future owners (e.g. users) can attach files;
            // today the only attachable is a task.
            $table->morphs('attachable');
            $table->string('kind', 16);
            $table->string('path');
            $table->string('original_name');
            $table->string('mime_type', 128);
            // Size in bytes; the 5 MB per-file cap is enforced at upload.
            $table->unsignedInteger('size');
            $table->foreignId('uploaded_by')->constrained('users');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('attachments');
    }
};
