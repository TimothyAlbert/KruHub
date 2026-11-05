<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('divisions')) {
            Schema::create('divisions', function (Blueprint $table) {
                $table->id();
                $table->foreignId('team_id')->nullable()->constrained('teams')->nullOnDelete();
                $table->string('name');
                $table->string('slug');
                $table->text('description')->nullable();
                $table->timestamps();
                $table->unique(['team_id', 'name']);
                $table->unique(['team_id', 'slug']);
            });
        } elseif (!Schema::hasColumn('divisions', 'team_id')) {
            Schema::table('divisions', function (Blueprint $table) {
                $table->foreignId('team_id')->nullable()->after('id')->constrained('teams')->nullOnDelete();
                $table->unique(['team_id', 'name']);
                $table->unique(['team_id', 'slug']);
            });
        }

        if (Schema::hasColumn('users', 'division')) {
            Schema::table('users', function (Blueprint $table) {
                $table->dropColumn('division');
            });
        }

        if (Schema::hasColumn('users', 'division_id')) {
            Schema::table('users', function (Blueprint $table) {
                $table->dropConstrainedForeignId('division_id');
            });
        }
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (Schema::hasColumn('users', 'division_id')) {
                $table->dropConstrainedForeignId('division_id');
            }
        });

        Schema::dropIfExists('divisions');
    }
};
