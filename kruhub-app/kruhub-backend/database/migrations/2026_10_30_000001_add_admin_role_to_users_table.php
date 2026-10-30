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

        $columns = DB::select('SHOW COLUMNS FROM users');
        $existingColumns = array_map(fn ($column) => strtolower($column->Field), $columns);

        if (!in_array('position', $existingColumns, true)) {
            DB::statement('ALTER TABLE users ADD COLUMN position VARCHAR(255) NULL AFTER division');
        }

        if (!in_array('phone', $existingColumns, true)) {
            DB::statement('ALTER TABLE users ADD COLUMN phone VARCHAR(255) NULL AFTER position');
        }

        if (!in_array('bio', $existingColumns, true)) {
            DB::statement('ALTER TABLE users ADD COLUMN bio TEXT NULL AFTER phone');
        }

        DB::statement("ALTER TABLE users MODIFY COLUMN role VARCHAR(32) NULL");
        DB::statement("UPDATE users SET role = LOWER(TRIM(role)) WHERE role IS NOT NULL");
        DB::statement("UPDATE users SET role = 'user' WHERE role IS NULL OR TRIM(role) = '' OR LOWER(TRIM(role)) NOT IN ('admin', 'user')");
        DB::statement("ALTER TABLE users MODIFY COLUMN role VARCHAR(32) NOT NULL DEFAULT 'user'");
    }

    public function down(): void
    {
        if (DB::getDriverName() === 'sqlite') {
            return;
        }

        $columns = DB::select('SHOW COLUMNS FROM users');
        $existingColumns = array_map(fn ($column) => strtolower($column->Field), $columns);

        foreach (['bio', 'phone', 'position'] as $column) {
            if (in_array($column, $existingColumns, true)) {
                DB::statement("ALTER TABLE users DROP COLUMN {$column}");
            }
        }

        DB::statement("ALTER TABLE users MODIFY COLUMN role VARCHAR(32) NOT NULL DEFAULT 'user'");
    }
};