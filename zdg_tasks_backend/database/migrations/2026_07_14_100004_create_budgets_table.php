<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('budgets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained('companies');
            $table->string('department');
            $table->string('period_type', 16);
            $table->date('period_start');
            $table->date('period_end');
            // Integer minor units (ngwee). Drawn down by funded_amount.
            $table->unsignedBigInteger('amount');
            $table->foreignId('set_by')->constrained('users');
            $table->timestamps();

            // One budget per department and period within a company.
            $table->unique(['company_id', 'department', 'period_start', 'period_end']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('budgets');
    }
};
