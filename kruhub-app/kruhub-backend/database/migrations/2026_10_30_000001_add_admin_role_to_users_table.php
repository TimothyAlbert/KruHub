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

        // Beberapa record lama bisa memiliki role yang tidak sesuai dengan nama-nama role baru.
        // Pastikan data invalid di-normalisasi dulu sebelum mengubah tipe kolom.
        DB::statement("UPDATE users SET role = 'member' WHERE role IS NULL OR TRIM(role) = '' OR role NOT IN ('owner', 'project_lead', 'division_lead', 'member', 'admin')");

        // Gunakan VARCHAR agar tidak crash karena data lama atau value yang tidak cocok dengan ENUM.
        DB::statement("ALTER TABLE users MODIFY COLUMN role VARCHAR(32) NOT NULL DEFAULT 'member'");
    }

    public function down(): void
    {
        if (DB::getDriverName() === 'sqlite') {
            return;
        }

        DB::statement("UPDATE users SET role = 'member' WHERE role IS NULL OR TRIM(role) = '' OR role NOT IN ('owner', 'project_lead', 'division_lead', 'member')");
        DB::statement("ALTER TABLE users MODIFY COLUMN role VARCHAR(32) NOT NULL DEFAULT 'member'");
    }
};
