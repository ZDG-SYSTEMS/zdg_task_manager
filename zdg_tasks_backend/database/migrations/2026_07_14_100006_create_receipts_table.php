<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('receipts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('task_id')->constrained('tasks');
            $table->foreignId('attachment_id')->constrained('attachments');
            // Integer minor units (ngwee). Verified receipts drive
            // amount_accounted and who-was-paid reporting.
            $table->unsignedBigInteger('amount');
            $table->boolean('verified')->default(false);
            $table->foreignId('verified_by')->nullable()->constrained('users');
            $table->timestamp('verified_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('receipts');
    }
};
