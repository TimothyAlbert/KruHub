<?php

use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\AssetController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\TaskController;
use App\Http\Controllers\TeamController;
use Illuminate\Support\Facades\Route;

// Public Routes
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

// Protected Routes (Butuh Sanctum Bearer Token)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);

    // Teams / Projects API
    Route::get('/user/teams', [TeamController::class, 'userTeams']);
    Route::post('/teams', [TeamController::class, 'store']);
    Route::post('/teams/join', [TeamController::class, 'join']);
    Route::get('/team/members', [TeamController::class, 'members']);

    // Dashboard Summary
    Route::get('/dashboard/summary', [DashboardController::class, 'summary']);

    // Tasks API
    Route::apiResource('tasks', TaskController::class);

    // Assets API
    Route::apiResource('assets', AssetController::class);
});