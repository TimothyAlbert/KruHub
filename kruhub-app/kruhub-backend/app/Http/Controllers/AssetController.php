<?php

namespace App\Http\Controllers;

use App\Models\Asset;
use Illuminate\Http\Request;

class AssetController extends Controller
{
    public function index(Request $request)
    {
        $teamId = $request->header('X-Project-ID');

        if (!$teamId) {
            return response()->json([]);
        }

        $assets = Asset::where('team_id', $teamId)
            ->latest()
            ->get();

        return response()->json($assets);
    }

    public function store(Request $request)
    {
        $teamId = $request->header('X-Project-ID');

        if (!$teamId) {
            return response()->json(['message' => 'Silakan pilih project terlebih dahulu.'], 400);
        }

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'category' => 'required|string',
            'location' => 'required|string',
            'status' => 'nullable|in:Available,In Use,Maintenance',
        ]);

        $asset = Asset::create([
            'team_id' => $teamId,
            'name' => $validated['name'],
            'category' => $validated['category'],
            'location' => $validated['location'],
            'status' => $validated['status'] ?? 'Available',
        ]);

        return response()->json([
            'message' => 'Aset berhasil ditambahkan.',
            'data' => $asset
        ], 201);
    }

    public function show(Request $request, $id)
    {
        $teamId = $request->header('X-Project-ID');
        $asset = Asset::where('team_id', $teamId)->findOrFail($id);

        return response()->json($asset);
    }

    public function update(Request $request, $id)
    {
        $teamId = $request->header('X-Project-ID');
        $asset = Asset::where('team_id', $teamId)->findOrFail($id);

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'category' => 'sometimes|string',
            'location' => 'sometimes|string',
            'status' => 'sometimes|in:Available,In Use,Maintenance',
        ]);

        $asset->update($validated);

        return response()->json([
            'message' => 'Aset berhasil diperbarui.',
            'data' => $asset
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $teamId = $request->header('X-Project-ID');
        $asset = Asset::where('team_id', $teamId)->findOrFail($id);
        $asset->delete();

        return response()->json(['message' => 'Aset berhasil dihapus.']);
    }
}