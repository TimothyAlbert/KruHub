<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
{
    Schema::table('teams', function (Blueprint $table) {
        $table->string('project_type')->nullable()->after('description'); // Sesuaikan posisi jika perlu
    });
}

public function down(): void
{
    Schema::table('teams', function (Blueprint $table) {
        $table->dropColumn('project_type');
    });
}
};
