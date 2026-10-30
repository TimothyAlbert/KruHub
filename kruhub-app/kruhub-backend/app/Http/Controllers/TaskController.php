<?php

namespace App\Http\Controllers;

use App\Models\Task;
use App\Models\Team;
use Illuminate\Http\Request;

class TaskController extends Controller
{
    public function index(Request $request)
    {
        $teamId = $request->header('X-Project-ID');

        if (!$teamId) {
            return response()->json([]);
        }

        $team = Team::findOrFail($teamId);
        $query = Task::with('creator')->where('team_id', $teamId);

        if ($request->filled('division')) {
            $query->where('division', $request->division);
        }

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        $tasks = $query->latest()->get();

        if (!$team->canManageMembers($request->user()) && $request->user()->division) {
            $tasks = $tasks->filter(function (Task $task) use ($request) {
                return $task->division === $request->user()->division || $task->division === 'General';
            })->values();
        }

        return response()->json($tasks);
    }

    public function store(Request $request)
    {
        $user = $request->user();
        $teamId = $request->header('X-Project-ID');

        if (!$teamId) {
            return response()->json(['message' => 'Silakan pilih project terlebih dahulu.'], 400);
        }

        $team = Team::findOrFail($teamId);
        $division = $request->division ?? $user->division ?? 'General';

        if (!$team->canManageMembers($user) && !$team->canManageDivision($user, $division)) {
            return response()->json(['message' => 'Anda tidak memiliki izin menambahkan task di divisi ini.'], 403);
        }

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'division' => 'required|string',
            'status' => 'nullable|in:In Progress,Review,Blocked,Completed',
            'deadline_date' => 'nullable|date',
        ]);

        $task = Task::create([
            'team_id' => $teamId,
            'title' => $validated['title'],
            'division' => $validated['division'],
            'status' => $validated['status'] ?? 'In Progress',
            'deadline_date' => $validated['deadline_date'] ?? null,
            'created_by' => $user->id,
        ]);

        return response()->json([
            'message' => 'Tugas berhasil dibuat.',
            'data' => $task->load('creator')
        ], 201);
    }

    public function show(Request $request, $id)
    {
        $teamId = $request->header('X-Project-ID');
        $team = Team::findOrFail($teamId);
        $task = Task::where('team_id', $teamId)->with('creator')->findOrFail($id);

        if (!$team->canManageMembers($request->user()) && $request->user()->division && $task->division !== $request->user()->division) {
            return response()->json(['message' => 'Anda tidak memiliki akses ke task ini.'], 403);
        }

        return response()->json($task);
    }

    public function update(Request $request, $id)
    {
        $teamId = $request->header('X-Project-ID');
        $team = Team::findOrFail($teamId);
        $task = Task::where('team_id', $teamId)->findOrFail($id);

        if (!$team->canManageMembers($request->user()) && $request->user()->division && $task->division !== $request->user()->division) {
            return response()->json(['message' => 'Anda tidak memiliki izin mengubah task ini.'], 403);
        }

        $validated = $request->validate([
            'title' => 'sometimes|string|max:255',
            'division' => 'sometimes|string',
            'status' => 'sometimes|in:In Progress,Review,Blocked,Completed',
            'deadline_date' => 'nullable|date',
        ]);

        $task->update($validated);

        return response()->json([
            'message' => 'Tugas berhasil diperbarui.',
            'data' => $task->fresh('creator')
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $teamId = $request->header('X-Project-ID');
        $team = Team::findOrFail($teamId);
        $task = Task::where('team_id', $teamId)->findOrFail($id);

        if (!$team->canManageMembers($request->user()) && $request->user()->division && $task->division !== $request->user()->division) {
            return response()->json(['message' => 'Anda tidak memiliki izin menghapus task ini.'], 403);
        }

        $task->delete();

        return response()->json(['message' => 'Tugas berhasil dihapus.']);
    }
}