<?php

namespace App\Http\Controllers;

use App\Models\Team;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class TeamController extends Controller
{
    // 1. BUAT TIM BARU & OTOMATIS GABUNGKAN PEMBUAT SEBAGAI OWNER
    public function store(Request $request)
    {
        try {
            $request->validate([
                'name' => 'required|string|max:255',
                'team_code' => 'required|string|unique:teams,team_code',
                'description' => 'nullable|string',
            ]);

            $team = Team::create([
                'name' => $request->name,
                'team_code' => $request->team_code,
                'description' => $request->description,
            ]);

            // Selalu tetapkan pembuat tim dengan role 'owner' di pivot table
            $team->members()->attach($request->user()->id, [
                'role' => 'owner'
            ]);

            return response()->json([
                'message' => 'Project berhasil dibuat dan Anda otomatis menjadi Owner!',
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

    // 2. AMBIL DAFTAR TIM DIIKUTI USER
    public function userTeams(Request $request)
    {
        try {
            $teams = $request->user()->teams;
            return response()->json($teams);
        } catch (\Throwable $e) {
            Log::error('Error fetching user teams: ' . $e->getMessage());
            return response()->json([]);
        }
    }

    // 3. GABUNG TIM LEWAT KODE SEBAGAI MEMBER
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

            if ($team->members()->where('user_id', $request->user()->id)->exists()) {
                return response()->json(['message' => 'Anda sudah bergabung di tim ini'], 400);
            }

            // Pendaftar baru via kode tim ditetapkan sebagai 'member'
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

    // 4. DAFTAR ANGGOTA TIM AKTIF BERDASARKAN X-PROJECT-ID
    public function members(Request $request)
    {
        $teamId = $request->header('X-Project-ID');

        if (!$teamId) {
            return response()->json([]);
        }

        $team = Team::find($teamId);

        if (!$team) {
            return response()->json([]);
        }

        // Mengembalikan anggota beserta data pivot-nya (pivot.role)
        return response()->json($team->members);
    }
}