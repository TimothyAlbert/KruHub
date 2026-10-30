<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    // 1. REGISTER
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        return response()->json([
            'message' => 'Registrasi berhasil.',
            'user' => $user
        ], 201);
    }

    // 2. LOGIN (Diperbarui: hapus with('team') yang menyebabkan error 500)
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Email atau password salah.'
            ], 401);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login berhasil.',
            'access_token' => $token,
            'token' => $token,
            'token_type' => 'Bearer',
            'user' => $user
        ]);
    }

    // 3. USER PROFILE
    public function user(Request $request)
    {
        return response()->json($request->user());
    }

    // 3b. LIST ALL USERS (ADMIN ONLY)
    public function allUsers(Request $request)
    {
        $this->ensureAdmin($request);

        $users = User::with('division')
            ->select('id', 'name', 'email', 'role', 'division', 'division_id', 'position', 'phone', 'bio', 'created_at')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($users);
    }

    public function createUser(Request $request)
    {
        $this->ensureAdmin($request);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users,email',
            'password' => 'required|string|min:6',
            'role' => 'required|string|in:admin,user',
            'division' => 'nullable|string|max:255',
            'division_id' => 'nullable|exists:divisions,id',
            'position' => 'nullable|string|max:255',
            'phone' => 'nullable|string|max:255',
            'bio' => 'nullable|string|max:1000',
        ]);

        $divisionId = $this->resolveDivisionId($validated['division'] ?? null, $validated['division_id'] ?? null);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'role' => $validated['role'],
            'division' => $validated['division'] ?? null,
            'division_id' => $divisionId,
            'position' => $validated['position'] ?? null,
            'phone' => $validated['phone'] ?? null,
            'bio' => $validated['bio'] ?? null,
        ]);

        return response()->json([
            'message' => 'User berhasil dibuat.',
            'user' => $this->sanitizeUser($user),
        ], 201);
    }

    public function showUser(Request $request, User $user)
    {
        $this->ensureAdmin($request);

        return response()->json($this->sanitizeUser($user));
    }

    public function updateUser(Request $request, User $user)
    {
        $this->ensureAdmin($request);

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|string|email|max:255|unique:users,email,' . $user->id,
            'password' => 'sometimes|string|min:6',
            'role' => 'sometimes|string|in:admin,user',
            'division' => 'nullable|string|max:255',
            'division_id' => 'nullable|exists:divisions,id',
            'position' => 'nullable|string|max:255',
            'phone' => 'nullable|string|max:255',
            'bio' => 'nullable|string|max:1000',
        ]);

        if ($user->id === $request->user()->id && isset($validated['role']) && $validated['role'] !== 'admin') {
            return response()->json([
                'message' => 'Admin utama tidak dapat menurunkan role sendiri dari admin.'
            ], 422);
        }

        $divisionId = $this->resolveDivisionId(
            $validated['division'] ?? $user->division,
            $validated['division_id'] ?? $user->division_id
        );

        foreach ($validated as $field => $value) {
            if ($field === 'password') {
                $user->password = Hash::make($value);
                continue;
            }

            if ($field === 'division' || $field === 'division_id') {
                continue;
            }

            $user->{$field} = $value;
        }

        if (array_key_exists('division', $validated) || array_key_exists('division_id', $validated)) {
            $user->division = $validated['division'] ?? $user->division;
            $user->division_id = $divisionId;
        }

        $user->save();

        return response()->json([
            'message' => 'User berhasil diperbarui.',
            'user' => $this->sanitizeUser($user->fresh()),
        ]);
    }

    public function deleteUser(Request $request, User $user)
    {
        $this->ensureAdmin($request);

        if ($request->user()->id === $user->id) {
            return response()->json([
                'message' => 'Admin tidak dapat menghapus akun sendiri.'
            ], 422);
        }

        $user->delete();

        return response()->json([
            'message' => 'User berhasil dihapus.'
        ]);
    }

    // 4. LOGOUT
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Berhasil logout.'
        ]);
    }

    protected function ensureAdmin(Request $request): void
    {
        if (($request->user()->role ?? '') !== 'admin') {
            abort(403, 'Akses ditolak. Hanya admin yang dapat melakukan operasi ini.');
        }
    }

    protected function sanitizeUser(User $user): array
    {
        $division = $user->relationLoaded('division') ? $user->division : $user->division()->first();

        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'division_id' => $user->division_id,
            'division' => $division?->name ?? $user->division,
            'position' => $user->position,
            'phone' => $user->phone,
            'bio' => $user->bio,
            'created_at' => $user->created_at,
            'updated_at' => $user->updated_at,
        ];
    }

    protected function resolveDivisionId(?string $divisionName, ?int $divisionId): ?int
    {
        if ($divisionId) {
            return $divisionId;
        }

        if (blank($divisionName)) {
            return null;
        }

        $division = \App\Models\Division::firstOrCreate(
            ['name' => trim($divisionName)],
            ['slug' => strtolower(str_replace(' ', '-', trim($divisionName)))]
        );

        return $division->id;
    }
}