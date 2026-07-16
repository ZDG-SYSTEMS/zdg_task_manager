<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Display identifier in the ABC000 format: company code plus a
            // zero-padded per-company sequence, e.g. ZDG001. The bigint id
            // stays the internal key for foreign keys.
            $table->string('code', 10)->unique()->after('id');
            $table->foreignId('company_id')->after('email')->constrained('companies');
            $table->string('department')->after('company_id');
            $table->string('branch')->nullable()->after('department');
            $table->string('position')->after('branch');
            // Null until technical assigns a role; assignment activates
            // the account (self-registration collects no role).
            $table->string('role', 32)->nullable()->after('position');
            $table->string('status', 16)->default('inactive')->after('role');

            $table->index(['company_id', 'role']);
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex(['company_id', 'role']);
            $table->dropConstrainedForeignId('company_id');
            $table->dropColumn(['code', 'department', 'branch', 'position', 'role', 'status']);
        });
    }
};
