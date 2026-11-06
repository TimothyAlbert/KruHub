<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasColumn('teams', 'project_type')) {
            Schema::table('teams', function (Blueprint $table) {
                $table->string('project_type')->nullable()->after('description');
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('teams', 'project_type')) {
            Schema::table('teams', function (Blueprint $table) {
                $table->dropColumn('project_type');
            });
        }
    }
};
