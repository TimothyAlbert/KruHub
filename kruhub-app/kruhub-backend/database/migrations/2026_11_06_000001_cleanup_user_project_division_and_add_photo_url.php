<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (Schema::hasColumn('users', 'team_id')) {
                $table->dropConstrainedForeignId('team_id');
            }

            if (Schema::hasColumn('users', 'division')) {
                $table->dropColumn('division');
            }

            if (Schema::hasColumn('users', 'division_id')) {
                $table->dropConstrainedForeignId('division_id');
            }
        });

        Schema::table('assets', function (Blueprint $table) {
            if (!Schema::hasColumn('assets', 'photo_url')) {
                $table->text('photo_url')->nullable();
            }
        });

        if (!Schema::hasColumn('divisions', 'team_id')) {
            Schema::table('divisions', function (Blueprint $table) {
                $table->foreignId('team_id')->nullable()->after('id')->constrained('teams')->nullOnDelete();
            });
        }
    }

    public function down(): void
    {
        Schema::table('assets', function (Blueprint $table) {
            if (Schema::hasColumn('assets', 'photo_url')) {
                $table->dropColumn('photo_url');
            }
        });

        Schema::table('divisions', function (Blueprint $table) {
            if (Schema::hasColumn('divisions', 'team_id')) {
                $table->dropConstrainedForeignId('team_id');
            }
        });

        Schema::table('users', function (Blueprint $table) {
            if (!Schema::hasColumn('users', 'team_id')) {
                $table->foreignId('team_id')->nullable()->constrained('teams')->nullOnDelete();
            }

            if (!Schema::hasColumn('users', 'division')) {
                $table->string('division')->nullable();
            }
        });
    }
};
