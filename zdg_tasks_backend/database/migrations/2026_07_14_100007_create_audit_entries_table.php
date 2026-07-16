<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Immutable log: rows are only ever inserted. The model exposes
        // no update or delete path and has no updated_at column.
        Schema::create('audit_entries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('task_id')->constrained('tasks');
            // Null actor marks a system-driven entry (e.g. escalation
            // by the daily job).
            $table->foreignId('actor_id')->nullable()->constrained('users');
            $table->string('actor_role', 32)->nullable();
            $table->foreignId('company_id')->constrained('companies');
            // from_state is null for the creation entry.
            $table->string('from_state', 24)->nullable();
            $table->string('to_state', 24);
            $table->text('reason')->nullable();
            $table->boolean('via_technical')->default(false);
            $table->timestamp('created_at');

            $table->index('task_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('audit_entries');
    }
};
