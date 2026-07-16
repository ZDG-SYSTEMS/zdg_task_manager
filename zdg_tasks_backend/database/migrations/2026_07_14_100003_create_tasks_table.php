<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tasks', function (Blueprint $table) {
            $table->id();
            // Single table for both task types, discriminated by type.
            $table->string('type', 16);
            $table->string('title');
            // Nullable so incomplete work can be saved as a draft;
            // submission validates completeness.
            $table->text('description')->nullable();
            // Why an auto-draft happened (network/server failure).
            $table->string('draft_reason')->nullable();
            $table->foreignId('created_by')->constrained('users');
            $table->foreignId('company_id')->constrained('companies');

            // All money columns are integer minor units (ngwee).
            $table->unsignedBigInteger('amount_requested')->nullable();
            $table->unsignedBigInteger('amount_approved')->nullable();
            $table->text('amount_edit_reason')->nullable();
            $table->char('currency', 3)->default('ZMW');

            $table->date('due_date')->nullable();
            $table->string('beneficiary_type', 8)->nullable();
            $table->string('beneficiary_name')->nullable();
            $table->boolean('receipt_required')->nullable();

            // Approver-visible only; recomputed daily by a scheduled job.
            $table->string('priority', 8)->nullable();
            $table->string('status', 24)->default('draft');
            // Overdue is a flag layered on live states, never a state.
            $table->boolean('overdue')->default(false);
            $table->boolean('via_technical')->default(false);
            $table->foreignId('assigned_funder_id')->nullable()->constrained('users');

            // Funding record: a data-only overlay written after approval.
            // Cash-released reporting reads funded_amount, never
            // amount_approved.
            $table->boolean('funded')->default(false);
            $table->timestamp('funded_at')->nullable();
            $table->string('funded_reference')->nullable();
            $table->unsignedBigInteger('funded_amount')->nullable();
            $table->foreignId('funded_by')->nullable()->constrained('users');

            // Petty cash (imprest) reconciliation figures.
            $table->unsignedBigInteger('amount_issued')->nullable();
            $table->unsignedBigInteger('amount_accounted')->nullable();
            $table->unsignedBigInteger('balance_returned')->nullable();
            $table->date('receipt_due_date')->nullable();
            $table->foreignId('recipient_id')->nullable()->constrained('users');

            $table->timestamps();

            $table->index(['company_id', 'status']);
            $table->index(['status', 'due_date']);
            $table->index('type');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tasks');
    }
};
