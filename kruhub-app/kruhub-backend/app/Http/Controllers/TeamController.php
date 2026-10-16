<?php

namespace App\Http\Controllers;

use App\Models\Team;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class TeamController extends Controller
{
    public function store(Request $request)
    {
        try {
            $request->validate([
                'name' => 'required|string|max:255',
                'team_code' => 'required|string|unique:teams,team_code',
                'description' => 'nullable|string',
            ]);

            // Hanya memasukkan field yang ada di migrasi
            $team = Team::create([
                'name' => $request->name,
                'team_code' => $request->team_code,
                'description' => $request->description,
            ]);

            // Hubungkan user yang sedang login ke team via pivot table jika ada
            if (method_exists($team, 'members')) {
                $team->members()->syncWithoutDetaching([$request->user()->id]);
            }

            return response()->json([
                'message' => 'Project/Team berhasil dibuat',
                'data' => $team
            ], 201);

        } catch (\Throwable $e) {
            Log::error('Gagal membuat team: ' . $e->getMessage());

            return response()->json([
                'message' => 'Gagal membuat team: ' . $e->getMessage()
            ], 500);
        }
    }
}