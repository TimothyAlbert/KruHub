<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('team_user', function (Blueprint $table) {
            if (!Schema::hasColumn('team_user', 'division_id')) {
                $table->foreignId('division_id')->nullable()->after('user_id')->constrained('divisions')->nullOnDelete();
            }
        });
    }

    public function down(): void
    {
        Schema::table('team_user', function (Blueprint $table) {
            if (Schema::hasColumn('team_user', 'division_id')) {
                $table->dropConstrainedForeignId('division_id');
            }
        });
    }
};
