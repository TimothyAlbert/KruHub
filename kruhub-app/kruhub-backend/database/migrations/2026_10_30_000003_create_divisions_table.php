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

        if (!Schema::hasColumn('users', 'division_id')) {
            Schema::table('users', function (Blueprint $table) {
                $table->foreignId('division_id')->nullable()->after('role')->constrained('divisions')->nullOnDelete();
            });
        }

        $existingDivisionNames = DB::table('users')
            ->whereNotNull('division')
            ->where('division', '!=', '')
            ->distinct()
            ->pluck('division');

        foreach ($existingDivisionNames as $divisionName) {
            $slug = strtolower(trim(preg_replace('/[^A-Za-z0-9]+/', '-', $divisionName)));
            $slug = trim($slug, '-');

            $division = DB::table('divisions')->where('name', $divisionName)->first();
            if (!$division) {
                $divisionId = DB::table('divisions')->insertGetId([
                    'name' => $divisionName,
                    'slug' => $slug ?: 'general',
                    'description' => null,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            } else {
                $divisionId = $division->id;
            }

            DB::table('users')
                ->where('division', $divisionName)
                ->update(['division_id' => $divisionId]);
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
