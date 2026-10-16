<?php

namespace App\Http\Controllers;

use App\Models\Team;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class TeamController extends Controller
{
    // 1. BUAT TIM BARU & OTOMATIS GABUNGKAN PEMBUAT
    public function store(Request $request)
    {
        try {
            $request->validate([
                'name' => 'required|string|max:255',
                'team_code' => 'required|string|unique:teams,team_code',
                'description' => 'nullable|string',
            ]);

            // 1. Simpan data tim
            $team = Team::create([
                'name' => $request->name,
                'team_code' => $request->team_code,
                'description' => $request->description,
            ]);

            // 2. OTOMATIS GABUNGKAN USER PEMBUAT SEBAGAI OWNER
            $team->members()->attach($request->user()->id, [
                'role' => 'owner'
            ]);

            return response()->json([
                'message' => 'Project berhasil dibuat dan Anda otomatis bergabung!',
                'data' => $team->load('members')
            ], 201);

        } catch (\Throwable $e) {
            Log::error('Error store team: ' . $e->getMessage());
            return response()->json([
                'message' => 'Gagal membuat team',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // 2. AMBIL TIM YANG DIIKUTI USER
    public function userTeams(Request $request)
    {
        try {
            // Mengambil semua tim di mana user terdaftar di pivot table
            $teams = $request->user()->teams;
            return response()->json($teams);
        } catch (\Throwable $e) {
            Log::error('Error fetching user teams: ' . $e->getMessage());
            return response()->json([]);
        }
    }

    // 3. GABUNG TIM LEWAT KODE
    public function join(Request $request)
    {
        try {
            $request->validate([
                'team_code' => 'required|string',
            ]);

            $team = Team::where('team_code', $request->team_code)->first();

            if (!$team) {
                return response()->json(['message' => 'Kode tim tidak ditemukan'], 404);
            }

            // Cek jika sudah bergabung
            if ($team->members()->where('user_id', $request->user()->id)->exists()) {
                return response()->json(['message' => 'Anda sudah bergabung di tim ini'], 400);
            }

            // Attach user sebagai member biasa
            $team->members()->attach($request->user()->id, [
                'role' => 'member'
            ]);

            return response()->json([
                'message' => 'Berhasil bergabung ke project!',
                'data' => $team
            ], 200);

        } catch (\Throwable $e) {
            Log::error('Error join team: ' . $e->getMessage());
            return response()->json([
                'message' => 'Gagal bergabung ke team',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}