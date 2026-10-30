<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        if (DB::getDriverName() === 'sqlite') {
            return;
        }

        // Role utama global adalah hanya admin atau user biasa.
        // Role proyek seperti owner / project_lead / division_lead / member dibawa di pivot team_user.
        DB::statement("UPDATE users SET role = 'user' WHERE role IS NULL OR TRIM(role) = '' OR role NOT IN ('admin', 'user')");

        DB::statement("ALTER TABLE users MODIFY COLUMN role VARCHAR(32) NOT NULL DEFAULT 'user'");
    }

    public function down(): void
    {
        if (DB::getDriverName() === 'sqlite') {
            return;
        }

        DB::statement("UPDATE users SET role = 'user' WHERE role IS NULL OR TRIM(role) = '' OR role NOT IN ('admin', 'user')");
        DB::statement("ALTER TABLE users MODIFY COLUMN role VARCHAR(32) NOT NULL DEFAULT 'user'");
    }
};
