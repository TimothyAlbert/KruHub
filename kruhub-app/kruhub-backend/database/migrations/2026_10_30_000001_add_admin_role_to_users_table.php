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

        // 1. Ubah dulu kolom 'role' menjadi VARCHAR secara paksa 
        // agar batasan ENUM lama hilang dan tidak memicu warning/error truncate saat update.
        DB::statement("ALTER TABLE users MODIFY COLUMN role VARCHAR(32) NULL");

        // 2. Baru lakukan normalisasi data lama yang tidak valid
        DB::statement("UPDATE users SET role = 'member' WHERE role IS NULL OR TRIM(role) = '' OR role NOT IN ('owner', 'project_lead', 'division_lead', 'member', 'admin')");

        // 3. Pastikan struktur akhir kolomnya sesuai dengan standar yang diinginkan
        DB::statement("ALTER TABLE users MODIFY COLUMN role VARCHAR(32) NOT NULL DEFAULT 'member'");
    }

    public function down(): void
    {
        if (DB::getDriverName() === 'sqlite') {
            return;
        }

        DB::statement("ALTER TABLE users MODIFY COLUMN role VARCHAR(32) NOT NULL DEFAULT 'member'");
    }
};