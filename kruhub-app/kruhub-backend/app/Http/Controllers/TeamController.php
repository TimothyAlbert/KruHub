<?php

namespace App\Http\Controllers;

use App\Models\Team;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class TeamController extends Controller
{
    public function store(Request $request)
    {
        try {
            $request->validate([
                'name' => 'required|string|max:255',
                'team_code' => 'nullable|string|max:50|unique:teams,team_code',
                'description' => 'nullable|string',
                'project_type' => 'nullable|string|max:255',
                'project_status' => 'nullable|string|max:255',
                'client_name' => 'nullable|string|max:255',
                'budget' => 'nullable|string|max:255',
                'start_date' => 'nullable|date',
                'end_date' => 'nullable|date|after_or_equal:start_date',
                'location' => 'nullable|string|max:255',
                'objective' => 'nullable|string',
                'scope' => 'nullable|string',
            ]);

            $teamCode = $request->team_code ?: Team::generateUniqueTeamCode();

            $team = Team::create([
                'name' => $request->name,
                'team_code' => $teamCode,
                'description' => $request->description,
                'project_type' => $request->project_type,
                'project_status' => $request->project_status ?? 'Planning',
                'client_name' => $request->client_name,
                'budget' => $request->budget,
                'start_date' => $request->start_date,
                'end_date' => $request->end_date,
                'location' => $request->location,
                'objective' => $request->objective,
                'scope' => $request->scope,
                'owner_id' => $request->user()->id,
            ]);

            $team->members()->attach($request->user()->id, [
                'role' => 'owner',
            ]);

            return response()->json([
                'message' => 'Project berhasil dibuat dan Anda otomatis menjadi Owner!',
                'data' => $team->load('members', 'owner')
            ], 201);
        } catch (\Throwable $e) {
            Log::error('Error store team: ' . $e->getMessage());
            return response()->json([
                'message' => 'Gagal membuat project',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    public function userTeams(Request $request)
    {
        try {
            $teams = $request->user()->teams()->with('owner')->get();
            return response()->json($teams);
        } catch (\Throwable $e) {
            Log::error('Error fetching user teams: ' . $e->getMessage());
            return response()->json([]);
        }
    }

    public function join(Request $request)
    {
        try {
            $request->validate([
                'team_code' => 'required|string',
                'division' => 'nullable|string',
                'division_id' => 'nullable|exists:divisions,id',
                'role' => 'nullable|string|in:member,project_lead,division_lead',
            ]);

            $team = Team::where('team_code', $request->team_code)->first();

            if (!$team) {
                return response()->json(['message' => 'Kode project tidak ditemukan'], 404);
            }

            if ($team->members()->where('user_id', $request->user()->id)->exists()) {
                return response()->json(['message' => 'Anda sudah bergabung di project ini'], 400);
            }

            $divisionId = $request->filled('division_id')
                ? $request->division_id
                : (function () use ($request) {
                    if (!filled($request->division)) {
                        return null;
                    }

                    $division = \App\Models\Division::firstOrCreate([
                        'name' => trim($request->division),
                    ], [
                        'slug' => strtolower(str_replace(' ', '-', trim($request->division))),
                    ]);

                    return $division->id;
                })();

            $request->user()->teams()->attach($team->id, [
                'role' => $request->role ?? 'member',
                'division_id' => $divisionId,
            ]);

            return response()->json([
                'message' => 'Berhasil bergabung ke project!',
                'data' => $team,
            ], 200);
        } catch (\Throwable $e) {
            Log::error('Error join team: ' . $e->getMessage());
            return response()->json([
                'message' => 'Gagal bergabung ke project',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    public function members(Request $request)
    {
        $teamId = $request->header('X-Project-ID');

        if (!$teamId) {
            return response()->json([]);
        }

        $team = Team::with('members')->find($teamId);

        if (!$team) {
            return response()->json([]);
        }

        return response()->json($team->members->map(function (User $user) use ($team) {
            $pivotDivision = $user->pivot?->division_id ? \App\Models\Division::find($user->pivot->division_id) : null;

            return [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'division' => $pivotDivision?->name ?? 'General',
                'division_id' => $user->pivot?->division_id,
                'role' => $user->pivot->role ?? 'member',
                'position' => $user->position,
                'phone' => $user->phone,
                'can_manage_members' => $team->canManageMembers($user),
            ];
        }));
    }

    public function updateMember(Request $request, $userId)
    {
        $teamId = $request->header('X-Project-ID');
        $team = Team::findOrFail($teamId);

        if (!$team->canManageMembers($request->user())) {
            return response()->json(['message' => 'Anda tidak memiliki izin untuk mengelola anggota project'], 403);
        }

        $member = $team->members()->where('users.id', $userId)->firstOrFail();

        $validated = $request->validate([
            'role' => 'sometimes|in:owner,project_lead,division_lead,member',
            'division' => 'sometimes|string|max:255',
            'division_id' => 'sometimes|nullable|exists:divisions,id',
            'position' => 'sometimes|string|max:255',
        ]);

        $member->pivot->role = $validated['role'] ?? $member->pivot->role;
        $member->position = $validated['position'] ?? $member->position;
        $member->save();

        $pivotDivisionId = $validated['division_id'] ?? $member->pivot->division_id ?? null;

        if (array_key_exists('division', $validated) && !blank($validated['division'])) {
            $division = \App\Models\Division::firstOrCreate([
                'name' => trim((string) $validated['division']),
            ], [
                'slug' => strtolower(str_replace(' ', '-', trim((string) $validated['division']))),
            ]);
            $pivotDivisionId = $division->id;
        }

        $team->members()->updateExistingPivot($member->id, [
            'role' => $member->pivot->role,
            'division_id' => $pivotDivisionId,
        ]);

        return response()->json([
            'message' => 'Anggota project berhasil diperbarui.',
            'data' => $member,
        ]);
    }

    public function removeMember(Request $request, $userId)
    {
        $teamId = $request->header('X-Project-ID');
        $team = Team::findOrFail($teamId);

        if (!$team->canManageMembers($request->user())) {
            return response()->json(['message' => 'Anda tidak memiliki izin untuk menghapus anggota project'], 403);
        }

        if ((int) $request->user()->id === (int) $userId) {
            return response()->json(['message' => 'Anda tidak dapat menghapus diri sendiri dari project'], 422);
        }

        $team->members()->detach($userId);

        return response()->json(['message' => 'Anggota project berhasil dihapus.']);
    }
}