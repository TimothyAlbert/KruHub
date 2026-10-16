<?php

namespace App\Http\Controllers;

use App\Models\Team;
use Illuminate\Http\Request;

class TeamController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'team_code' => 'required|string|unique:teams,team_code',
            'description' => 'nullable|string',
            'roles' => 'nullable|array',
        ]);

        $team = Team::create([
            'name' => $request->name,
            'team_code' => $request->team_code,
            'description' => $request->description,
            'roles' => $request->roles ?? [],
            'owner_id' => $request->user()->id,
        ]);

        // Hubungkan pembuat tim sebagai anggota tim
        if (method_exists($team, 'members')) {
            $team->members()->attach($request->user()->id);
        }

        return response()->json([
            'message' => 'Project/Team berhasil dibuat',
            'data' => $team
        ], 201);
    }

    public function userTeams(Request $request)
    {
        // Mengambil daftar tim tempat user menjadi anggota
        $teams = Team::whereHas('members', function ($q) use ($request) {
            $q->where('user_id', $request->user()->id);
        })->get();

        return response()->json($teams);
    }

    public function join(Request $request)
    {
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

        $team->members()->attach($request->user()->id);

        return response()->json([
            'message' => 'Berhasil bergabung ke project',
            'data' => $team
        ], 200);
    }
}