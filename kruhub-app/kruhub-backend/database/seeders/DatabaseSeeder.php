<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Carbon\Carbon;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Matikan Foreign Key Check untuk mempermudah Reset
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        DB::table('assets')->truncate();
        DB::table('tasks')->truncate();
        DB::table('users')->truncate();
        DB::table('teams')->truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        // ----------------------------------------------------
        // 2. SEED TEAMS / PROJECTS
        // ----------------------------------------------------
        $team1Id = DB::table('teams')->insertGetId([
            'name' => 'Skyline Feature Film',
            'team_code' => 'KRU-U-8F3K2',
            'description' => 'Proyek pembuatan film layar lebar fiksi ilmiah Skyline.',
            'created_at' => Carbon::now(),
            'updated_at' => Carbon::now(),
        ]);

        $team2Id = DB::table('teams')->insertGetId([
            'name' => 'Nusantara Documentary',
            'team_code' => 'KRU-A-9X2M1',
            'description' => 'Eksplorasi dokumenter kebudayaan dan keanekaragaman Nusantara.',
            'created_at' => Carbon::now(),
            'updated_at' => Carbon::now(),
        ]);

        // ----------------------------------------------------
        // 3. SEED USERS
        // ----------------------------------------------------
        $passwordHash = Hash::make('password123');

        // Backup Admin (akses penuh jika project utama bermasalah)
        $adminUserId = DB::table('users')->insertGetId([
            'team_id' => null,
            'name' => 'KruHub Backup Admin',
            'email' => 'admin@kruhub.com',
            'password' => $passwordHash,
            'role' => 'admin',
            'division' => 'System Administration',
            'position' => 'Platform Administrator',
            'phone' => '081234567890',
            'bio' => 'Akun backup admin untuk monitoring dan pemulihan proyek jika terjadi kendala operasional.',
            'created_at' => Carbon::now(),
            'updated_at' => Carbon::now(),
        ]);

        // Semua anggota normal memiliki role utama user.
        // Role proyek spesifik (owner/project lead/etc.) disimpan di pivot team_user.
        $userCameraPIC = DB::table('users')->insertGetId([
            'team_id' => $team1Id,
            'name' => 'Budi Santoso',
            'email' => 'budi.camera@kruhub.com',
            'password' => $passwordHash,
            'role' => 'user',
            'division' => 'Kamera & Sinematografi',
            'created_at' => Carbon::now(),
            'updated_at' => Carbon::now(),
        ]);

        $userSoundPIC = DB::table('users')->insertGetId([
            'team_id' => $team1Id,
            'name' => 'Siti Rahma',
            'email' => 'siti.sound@kruhub.com',
            'password' => $passwordHash,
            'role' => 'user',
            'division' => 'Audio & Tata Suara',
            'created_at' => Carbon::now(),
            'updated_at' => Carbon::now(),
        ]);

        $userStaff1 = DB::table('users')->insertGetId([
            'team_id' => $team1Id,
            'name' => 'Andi Wijaya',
            'email' => 'andi.staff@kruhub.com',
            'password' => $passwordHash,
            'role' => 'user',
            'division' => 'Lighting',
            'created_at' => Carbon::now(),
            'updated_at' => Carbon::now(),
        ]);

        // Anggota Tim Project 2 (Nusantara Documentary)
        $userDocLead = DB::table('users')->insertGetId([
            'team_id' => $team2Id,
            'name' => 'Maya Putri',
            'email' => 'maya.doc@kruhub.com',
            'password' => $passwordHash,
            'role' => 'user',
            'division' => 'Produser Exec',
            'created_at' => Carbon::now(),
            'updated_at' => Carbon::now(),
        ]);

        // ----------------------------------------------------
        // 4. SEED TASKS (PROJECT 1: Skyline Feature Film)
        // ----------------------------------------------------
        DB::table('tasks')->insert([
            [
                'team_id' => $team1Id,
                'title' => 'Finalisasi Script & Storyboard Scene 1-10',
                'division' => 'Directing',
                'status' => 'Completed',
                'deadline_date' => Carbon::now()->subDays(2)->format('Y-m-d'),
                'created_by' => $adminUserId,
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'team_id' => $team1Id,
                'title' => 'Sewa Lensa Anamorphic & Rencana Pencahayaan',
                'division' => 'Kamera & Sinematografi',
                'status' => 'In Progress',
                'deadline_date' => Carbon::now()->addDays(3)->format('Y-m-d'),
                'created_by' => $adminUserId,
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'team_id' => $team1Id,
                'title' => 'Review Audio Foley & Sound Effect Teaser',
                'division' => 'Audio & Tata Suara',
                'status' => 'Review',
                'deadline_date' => Carbon::now()->addDays(5)->format('Y-m-d'),
                'created_by' => $userSoundPIC,
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'team_id' => $team1Id,
                'title' => 'Persetujuan Izin Lokasi Hutan Pinus',
                'division' => 'Produksi',
                'status' => 'Blocked',
                'deadline_date' => Carbon::now()->addDays(1)->format('Y-m-d'),
                'created_by' => $adminUserId,
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'team_id' => $team1Id,
                'title' => 'Penyusunan Wardrobe Karakter Utama',
                'division' => 'Art & Wardrobe',
                'status' => 'In Progress',
                'deadline_date' => Carbon::now()->addDays(7)->format('Y-m-d'),
                'created_by' => $adminUserId,
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
        ]);

        // SEED TASKS (PROJECT 2: Nusantara Documentary)
        DB::table('tasks')->insert([
            [
                'team_id' => $team2Id,
                'title' => 'Riset Narasumber Budayawan Toraja',
                'division' => 'Riset',
                'status' => 'In Progress',
                'deadline_date' => Carbon::now()->addDays(4)->format('Y-m-d'),
                'created_by' => $userDocLead,
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'team_id' => $team2Id,
                'title' => 'Pengurusan Tiket & Akomodasi Tim Lapangan',
                'division' => 'Logistik',
                'status' => 'Completed',
                'deadline_date' => Carbon::now()->subDays(1)->format('Y-m-d'),
                'created_by' => $userDocLead,
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
        ]);

        // ----------------------------------------------------
        // 5. SEED ASSETS (PROJECT 1: Skyline Feature Film)
        // ----------------------------------------------------
        DB::table('assets')->insert([
            [
                'team_id' => $team1Id,
                'name' => 'RED V-Raptor 8K VV Camera Body',
                'category' => 'Kamera',
                'location' => 'Studio Utama (Rak A1)',
                'status' => 'In Use',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'team_id' => $team1Id,
                'name' => 'ARRI SkyPanel S60-C LED Light',
                'category' => 'Lighting',
                'location' => 'Gudang Alat Lighting',
                'status' => 'Available',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'team_id' => $team1Id,
                'name' => 'Sennheiser MKH 416 Shotgun Microphone',
                'category' => 'Audio',
                'location' => 'Audio Kit Case #2',
                'status' => 'Available',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'team_id' => $team1Id,
                'name' => 'DJI Ronin 2 Professional Gimbal',
                'category' => 'Grip & Stabilizer',
                'location' => 'Studio Utama (Rak C3)',
                'status' => 'Maintenance',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'team_id' => $team1Id,
                'name' => 'Cooke Anamorphic /i Full Frame Lens Set',
                'category' => 'Lensa',
                'location' => 'Vault Kamera',
                'status' => 'In Use',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
        ]);

        // SEED ASSETS (PROJECT 2: Nusantara Documentary)
        DB::table('assets')->insert([
            [
                'team_id' => $team2Id,
                'name' => 'Sony FX6 Cinema Line Camera',
                'category' => 'Kamera',
                'location' => 'Pekalongan Unit',
                'status' => 'In Use',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
            [
                'team_id' => $team2Id,
                'name' => 'DJI Mavic 3 Cine Drone',
                'category' => 'Drone',
                'location' => 'Koper Drone A',
                'status' => 'Available',
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
        ]);
    }
}