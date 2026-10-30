<?php

namespace App\Http\Controllers;

use App\Models\Asset;
use App\Models\Team;
use App\Models\Task;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class AssetController extends Controller
{
    public function index(Request $request)
    {
        $teamId = $request->header('X-Project-ID');

        if (!$teamId) {
            return response()->json([]);
        }

        $team = Team::findOrFail($teamId);
        $query = Asset::where('team_id', $teamId);

        if ($request->filled('division')) {
            $query->where('division', $request->division);
        }

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('approval_status')) {
            $query->where('approval_status', $request->approval_status);
        }

        $assets = $query->with(['task', 'approver'])->latest()->get();

        if (!$team->canManageMembers($request->user()) && $request->user()->division) {
            $assets = $assets->filter(function (Asset $asset) use ($request) {
                return $asset->division === $request->user()->division || $asset->division === 'General';
            })->values();
        }

        return response()->json($assets);
    }

    public function store(Request $request)
    {
        $teamId = $request->header('X-Project-ID');

        if (!$teamId) {
            return response()->json(['message' => 'Silakan pilih project terlebih dahulu.'], 400);
        }

        $team = Team::findOrFail($teamId);
        $isOwnerOrLead = $team->canManageMembers($request->user()) || $team->canManageDivision($request->user(), $request->division ?? $request->user()->division);

        if (!$isOwnerOrLead) {
            return response()->json(['message' => 'Anda tidak memiliki izin menambahkan asset untuk divisi ini.'], 403);
        }

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'category' => 'required|string',
            'division' => 'nullable|string',
            'location' => 'required|string',
            'status' => 'nullable|in:Available,In Use,Maintenance',
            'approval_status' => 'nullable|in:Pending,Approved,Rejected',
            'related_task_id' => 'nullable|exists:tasks,id',
            'description' => 'nullable|string',
        ]);

        $asset = Asset::create([
            'team_id' => $teamId,
            'name' => $validated['name'],
            'category' => $validated['category'],
            'division' => $validated['division'] ?? $request->user()->division ?? 'General',
            'location' => $validated['location'],
            'status' => $validated['status'] ?? 'Available',
            'approval_status' => $validated['approval_status'] ?? 'Pending',
            'related_task_id' => $validated['related_task_id'] ?? null,
            'description' => $validated['description'] ?? null,
            'created_by' => $request->user()->id,
        ]);

        return response()->json([
            'message' => 'Aset berhasil ditambahkan.',
            'data' => $asset->load(['task', 'approver'])
        ], 201);
    }

    public function show(Request $request, $id)
    {
        $teamId = $request->header('X-Project-ID');
        $asset = Asset::where('team_id', $teamId)->with(['task', 'approver'])->findOrFail($id);

        return response()->json($asset);
    }

    public function update(Request $request, $id)
    {
        $teamId = $request->header('X-Project-ID');
        $team = Team::findOrFail($teamId);
        $asset = Asset::where('team_id', $teamId)->findOrFail($id);

        if (!$team->canManageMembers($request->user()) && $request->user()->division !== $asset->division) {
            return response()->json(['message' => 'Anda tidak memiliki izin mengubah asset ini.'], 403);
        }

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'category' => 'sometimes|string',
            'division' => 'sometimes|string',
            'location' => 'sometimes|string',
            'status' => 'sometimes|in:Available,In Use,Maintenance',
            'approval_status' => 'sometimes|in:Pending,Approved,Rejected',
            'related_task_id' => 'sometimes|nullable|exists:tasks,id',
            'description' => 'sometimes|nullable|string',
        ]);

        $asset->update($validated);

        return response()->json([
            'message' => 'Aset berhasil diperbarui.',
            'data' => $asset->fresh(['task', 'approver'])
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $teamId = $request->header('X-Project-ID');
        $team = Team::findOrFail($teamId);
        $asset = Asset::where('team_id', $teamId)->findOrFail($id);

        if (!$team->canManageMembers($request->user()) && $request->user()->division !== $asset->division) {
            return response()->json(['message' => 'Anda tidak memiliki izin menghapus asset ini.'], 403);
        }

        $asset->delete();

        return response()->json(['message' => 'Aset berhasil dihapus.']);
    }

    public function approve(Request $request, $id)
    {
        $teamId = $request->header('X-Project-ID');
        $team = Team::findOrFail($teamId);

        if (!$team->canManageMembers($request->user())) {
            return response()->json(['message' => 'Hanya owner / project lead yang bisa menyetujui asset.'], 403);
        }

        $asset = Asset::where('team_id', $teamId)->findOrFail($id);

        $validated = $request->validate([
            'approval_status' => 'required|in:Approved,Rejected',
        ]);

        $asset->update([
            'approval_status' => $validated['approval_status'],
            'approved_by' => $request->user()->id,
        ]);

        return response()->json([
            'message' => 'Status approval asset berhasil diperbarui.',
            'data' => $asset->fresh(['approver'])
        ]);
    }
}