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
                $table->string('name')->unique();
                $table->string('slug')->unique();
                $table->text('description')->nullable();
                $table->timestamps();
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
