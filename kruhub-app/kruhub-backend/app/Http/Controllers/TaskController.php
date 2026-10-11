<?php

namespace App\Http\Controllers;

use App\Models\Task;
use Illuminate\Http\Request;

class TaskController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();

        $tasks = Task::with('creator')
            ->where('team_id', $user->team_id)
            ->latest()
            ->get();

        return response()->json($tasks);
    }

    public function store(Request $request)
    {
        $user = $request->user();

        if (!in_array($user->role, ['ketua_pelaksana', 'pic_divisi'])) {
            return response()->json(['message' => 'Akses ditolak. Hanya Ketua dan PIC yang dapat membuat tugas.'], 403);
        }

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'division' => 'required|string',
            'status' => 'nullable|in:In Progress,Review,Blocked,Completed',
            'deadline_date' => 'nullable|date',
        ]);

        $task = Task::create([
            'team_id' => $user->team_id,
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
        $user = $request->user();
        $task = Task::where('team_id', $user->team_id)->findOrFail($id);

        return response()->json($task->load('creator'));
    }

    public function update(Request $request, $id)
    {
        $user = $request->user();
        $task = Task::where('team_id', $user->team_id)->findOrFail($id);

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
        $user = $request->user();

        if ($user->role !== 'ketua_pelaksana') {
            return response()->json(['message' => 'Akses ditolak. Hanya Ketua Pelaksana yang dapat menghapus tugas.'], 403);
        }

        $task = Task::where('team_id', $user->team_id)->findOrFail($id);
        $task->delete();

        return response()->json(['message' => 'Tugas berhasil dihapus.']);
    }
}