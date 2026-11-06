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
        $query = Task::with(['creator', 'assignee', 'approver'])->where('team_id', $teamId);

        if ($request->filled('division')) {
            $query->where('division', $request->division);
        }

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('approval_status')) {
            $query->where('approval_status', $request->approval_status);
        }

        if ($request->filled('search')) {
            $search = trim((string) $request->search);
            $query->where(function ($subQuery) use ($search) {
                $subQuery->where('title', 'like', "%{$search}%")
                    ->orWhere('division', 'like', "%{$search}%")
                    ->orWhere('status', 'like', "%{$search}%");
            });
        }

        if ($request->filled('assignee_id')) {
            $query->where('assignee_id', $request->assignee_id);
        }

        $tasks = $query->latest()->get();
        $userDivision = $team->getUserDivision($request->user());

        if (!$team->canManageMembers($request->user()) && $userDivision) {
            $tasks = $tasks->filter(function (Task $task) use ($userDivision) {
                return $task->division === $userDivision || $task->division === 'General';
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
        $division = trim((string) ($request->division ?? $team->getUserDivision($user) ?? 'General'));
        $division = $division !== '' ? $division : 'General';

        if (!$team->canManageMembers($user) && !$team->canManageDivision($user, $division)) {
            return response()->json(['message' => 'Anda tidak memiliki izin menambahkan task di divisi ini.'], 403);
        }

        $request->merge(['division' => $division]);

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'division' => 'nullable|string|max:255',
            'status' => 'nullable|in:In Progress,Review,Blocked,Completed',
            'deadline_date' => 'nullable|date',
            'assignee_id' => 'nullable|exists:users,id',
            'approval_status' => 'nullable|in:Pending,Approved,Rejected',
        ]);

        if (!empty($validated['assignee_id'])) {
            $assignee = $team->members()->where('users.id', $validated['assignee_id'])->first();

            if (!$assignee) {
                return response()->json(['message' => 'Penanggung jawab tidak terdaftar di project ini.'], 422);
            }

            $assigneeDivision = $team->getUserDivision($assignee);
            if (!$team->canManageMembers($user) && $assigneeDivision !== $division) {
                return response()->json(['message' => 'Lead divisi hanya bisa mengassign anggota divisinya sendiri.'], 403);
            }
        }

        $task = Task::create([
            'team_id' => $teamId,
            'title' => $validated['title'],
            'division' => $validated['division'],
            'status' => $validated['status'] ?? 'In Progress',
            'deadline_date' => $validated['deadline_date'] ?? null,
            'created_by' => $user->id,
            'assignee_id' => $validated['assignee_id'] ?? null,
            'approval_status' => $validated['approval_status'] ?? 'Pending',
            'approved_by' => null,
        ]);

        return response()->json([
            'message' => 'Tugas berhasil dibuat.',
            'data' => $task->load(['creator', 'assignee', 'approver'])
        ], 201);
    }

    public function show(Request $request, $id)
    {
        $teamId = $request->header('X-Project-ID');
        $team = Team::findOrFail($teamId);
        $task = Task::where('team_id', $teamId)->with(['creator', 'assignee', 'approver'])->findOrFail($id);
        $userDivision = $team->getUserDivision($request->user());

        if (!$team->canManageMembers($request->user()) && $userDivision && $task->division !== $userDivision) {
            return response()->json(['message' => 'Anda tidak memiliki akses ke task ini.'], 403);
        }

        return response()->json($task);
    }

    public function update(Request $request, $id)
    {
        $teamId = $request->header('X-Project-ID');
        $team = Team::findOrFail($teamId);
        $task = Task::where('team_id', $teamId)->findOrFail($id);
        $user = $request->user();
        $userDivision = $team->getUserDivision($user);

        if (!$team->canManageMembers($user) && $userDivision && $task->division !== $userDivision) {
            return response()->json(['message' => 'Anda tidak memiliki izin mengubah task ini.'], 403);
        }

        $validated = $request->validate([
            'title' => 'sometimes|string|max:255',
            'division' => 'sometimes|string',
            'status' => 'sometimes|in:In Progress,Review,Blocked,Completed',
            'deadline_date' => 'nullable|date',
            'assignee_id' => 'nullable|exists:users,id',
            'approval_status' => 'nullable|in:Pending,Approved,Rejected',
        ]);

        if (array_key_exists('assignee_id', $validated) && !empty($validated['assignee_id'])) {
            $assignee = $team->members()->where('users.id', $validated['assignee_id'])->first();
            if (!$assignee) {
                return response()->json(['message' => 'Penanggung jawab tidak terdaftar di project ini.'], 422);
            }

            $targetDivision = $validated['division'] ?? $task->division;
            if (!$team->canManageMembers($user) && $team->getUserDivision($assignee) !== $targetDivision) {
                return response()->json(['message' => 'Lead divisi hanya dapat mengassign anggota divisinya sendiri.'], 403);
            }
        }

        if (array_key_exists('approval_status', $validated) && !$team->canManageMembers($user) && !$team->isDivisionLead($user, $task->division)) {
            return response()->json(['message' => 'Hanya project owner atau lead divisi yang boleh menyetujui task.'], 403);
        }

        if (array_key_exists('approval_status', $validated)) {
            $task->approved_by = $user->id;
        }

        $task->update($validated);

        return response()->json([
            'message' => 'Tugas berhasil diperbarui.',
            'data' => $task->fresh(['creator', 'assignee', 'approver'])
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $teamId = $request->header('X-Project-ID');
        $team = Team::findOrFail($teamId);
        $task = Task::where('team_id', $teamId)->findOrFail($id);
        $userDivision = $team->getUserDivision($request->user());

        if (!$team->canManageMembers($request->user()) && $userDivision && $task->division !== $userDivision) {
            return response()->json(['message' => 'Anda tidak memiliki izin menghapus task ini.'], 403);
        }

        $task->delete();

        return response()->json(['message' => 'Tugas berhasil dihapus.']);
    }

    public function approve(Request $request, $id)
    {
        $teamId = $request->header('X-Project-ID');
        $team = Team::findOrFail($teamId);
        $task = Task::where('team_id', $teamId)->findOrFail($id);
        $user = $request->user();

        if (!$team->canManageMembers($user) && !$team->isDivisionLead($user, $task->division)) {
            return response()->json(['message' => 'Hanya project owner atau lead divisi yang bisa menyetujui task ini.'], 403);
        }

        $validated = $request->validate([
            'approval_status' => 'required|in:Approved,Rejected',
        ]);

        $task->update([
            'approval_status' => $validated['approval_status'],
            'approved_by' => $user->id,
        ]);

        return response()->json([
            'message' => 'Status approval task berhasil diperbarui.',
            'data' => $task->fresh(['creator', 'assignee', 'approver'])
        ]);
    }
}