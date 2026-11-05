<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('tasks', function (Blueprint $table) {
            if (!Schema::hasColumn('tasks', 'assignee_id')) {
                $table->foreignId('assignee_id')->nullable()->after('created_by')->constrained('users')->nullOnDelete();
            }

            if (!Schema::hasColumn('tasks', 'approval_status')) {
                $table->string('approval_status')->default('Pending')->after('assignee_id');
            }

            if (!Schema::hasColumn('tasks', 'approved_by')) {
                $table->foreignId('approved_by')->nullable()->after('approval_status')->constrained('users')->nullOnDelete();
            }
        });
    }

    public function down(): void
    {
        Schema::table('tasks', function (Blueprint $table) {
            if (Schema::hasColumn('tasks', 'approved_by')) {
                $table->dropConstrainedForeignId('approved_by');
            }

            if (Schema::hasColumn('tasks', 'approval_status')) {
                $table->dropColumn('approval_status');
            }

            if (Schema::hasColumn('tasks', 'assignee_id')) {
                $table->dropConstrainedForeignId('assignee_id');
            }
        });
    }
};
