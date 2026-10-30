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
        if (($request->user()->role ?? '') !== 'admin') {
            return response()->json([
                'message' => 'Akses ditolak. Hanya admin yang dapat melihat semua user.'
            ], 403);
        }

        $users = User::select('id', 'name', 'email', 'role', 'division', 'position', 'phone', 'bio', 'created_at')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($users);
    }

    // 4. LOGOUT
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Berhasil logout.'
        ]);
    }
}