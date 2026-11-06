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

        if (!Schema::hasColumn('teams', 'project_status')) {
            Schema::table('teams', function (Blueprint $table) {
                $table->string('project_status')->default('Planning')->after('project_type');
            });
        }

        if (!Schema::hasColumn('teams', 'client_name')) {
            Schema::table('teams', function (Blueprint $table) {
                $table->string('client_name')->nullable()->after('project_status');
            });
        }

        if (!Schema::hasColumn('teams', 'budget')) {
            Schema::table('teams', function (Blueprint $table) {
                $table->string('budget')->nullable()->after('client_name');
            });
        }

        if (!Schema::hasColumn('teams', 'start_date')) {
            Schema::table('teams', function (Blueprint $table) {
                $table->date('start_date')->nullable()->after('budget');
            });
        }

        if (!Schema::hasColumn('teams', 'end_date')) {
            Schema::table('teams', function (Blueprint $table) {
                $table->date('end_date')->nullable()->after('start_date');
            });
        }

        if (!Schema::hasColumn('teams', 'location')) {
            Schema::table('teams', function (Blueprint $table) {
                $table->string('location')->nullable()->after('end_date');
            });
        }

        if (!Schema::hasColumn('teams', 'objective')) {
            Schema::table('teams', function (Blueprint $table) {
                $table->text('objective')->nullable()->after('location');
            });
        }

        if (!Schema::hasColumn('teams', 'scope')) {
            Schema::table('teams', function (Blueprint $table) {
                $table->text('scope')->nullable()->after('objective');
            });
        }

        if (!Schema::hasColumn('teams', 'owner_id')) {
            Schema::table('teams', function (Blueprint $table) {
                $table->foreignId('owner_id')->nullable()->after('scope')->constrained('users')->nullOnDelete();
            });
        }
    }

    public function down(): void
    {
        $columns = ['owner_id', 'scope', 'objective', 'location', 'end_date', 'start_date', 'budget', 'client_name', 'project_status', 'project_type'];

        foreach ($columns as $column) {
            if (Schema::hasColumn('teams', $column)) {
                Schema::table('teams', function (Blueprint $table) use ($column) {
                    $table->dropColumn($column);
                });
            }
        }
    }
};
