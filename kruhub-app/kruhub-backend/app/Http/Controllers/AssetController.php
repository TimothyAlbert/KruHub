<?php

namespace App\Http\Controllers;

use App\Models\Asset;
use Illuminate\Http\Request;

class AssetController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();

        $assets = Asset::where('team_id', $user->team_id)
            ->latest()
            ->get();

        return response()->json($assets);
    }

    public function store(Request $request)
    {
        $user = $request->user();

        if ($user->role !== 'ketua_pelaksana') {
            return response()->json(['message' => 'Akses ditolak. Hanya Ketua Pelaksana yang dapat menambah aset.'], 403);
        }

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'category' => 'required|string',
            'location' => 'required|string',
            'status' => 'nullable|in:Available,In Use,Maintenance',
        ]);

        $asset = Asset::create([
            'team_id' => $user->team_id,
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
        $user = $request->user();
        $asset = Asset::where('team_id', $user->team_id)->findOrFail($id);

        return response()->json($asset);
    }

    public function update(Request $request, $id)
    {
        $user = $request->user();

        if (!in_array($user->role, ['ketua_pelaksana', 'pic_divisi'])) {
            return response()->json(['message' => 'Akses ditolak. Hanya Ketua dan PIC yang dapat memperbarui aset.'], 403);
        }

        $asset = Asset::where('team_id', $user->team_id)->findOrFail($id);

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
        $user = $request->user();

        if ($user->role !== 'ketua_pelaksana') {
            return response()->json(['message' => 'Akses ditolak. Hanya Ketua Pelaksana yang dapat menghapus aset.'], 403);
        }

        $asset = Asset::where('team_id', $user->team_id)->findOrFail($id);
        $asset->delete();

        return response()->json(['message' => 'Aset berhasil dihapus.']);
    }
}