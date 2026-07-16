<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Configurable registry driving report fields so accounts can
        // finalise reports without a rebuild (Phase 9).
        Schema::create('report_field_configs', function (Blueprint $table) {
            $table->id();
            // general / comparison / in_depth
            $table->string('report_tier', 16);
            $table->string('field_key', 64);
            $table->string('label');
            $table->boolean('enabled')->default(true);
            $table->unsignedInteger('sort_order')->default(0);
            $table->timestamps();

            $table->unique(['report_tier', 'field_key']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('report_field_configs');
    }
};
