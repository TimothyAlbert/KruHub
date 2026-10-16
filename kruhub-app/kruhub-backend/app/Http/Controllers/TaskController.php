<?php

namespace App\Http\Controllers;

use App\Models\Task;
use Illuminate\Http\Request;

class TaskController extends Controller
{
    public function index(Request $request)
    {
        $teamId = $request->header('X-Project-ID');

        if (!$teamId) {
            return response()->json([]);
        }

        $tasks = Task::with('creator')
            ->where('team_id', $teamId)
            ->latest()
            ->get();

        return response()->json($tasks);
    }

    public function store(Request $request)
    {
        $user = $request->user();
        $teamId = $request->header('X-Project-ID');

        if (!$teamId) {
            return response()->json(['message' => 'Silakan pilih project terlebih dahulu.'], 400);
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
            'data' => $task
        ], 201);
    }

    public function show(Request $request, $id)
    {
        $teamId = $request->header('X-Project-ID');
        $task = Task::where('team_id', $teamId)->findOrFail($id);

        return response()->json($task->load('creator'));
    }

    public function update(Request $request, $id)
    {
        $teamId = $request->header('X-Project-ID');
        $task = Task::where('team_id', $teamId)->findOrFail($id);

        $validated = $request->validate([
            'title' => 'sometimes|string|max:255',
            'division' => 'sometimes|string',
            'status' => 'sometimes|in:In Progress,Review,Blocked,Completed',
            'deadline_date' => 'nullable|date',
        ]);

        $task->update($validated);

        return response()->json([
            'message' => 'Tugas berhasil diperbarui.',
            'data' => $task
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $teamId = $request->header('X-Project-ID');
        $task = Task::where('team_id', $teamId)->findOrFail($id);
        $task->delete();

        return response()->json(['message' => 'Tugas berhasil dihapus.']);
    }
}