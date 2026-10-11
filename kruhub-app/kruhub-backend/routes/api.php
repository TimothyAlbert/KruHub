<?php

use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\AssetController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\TaskController;
use App\Http\Controllers\TeamController;
use Illuminate\Support\Facades\Route;

// Public Routes
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']); // Tambahan rute register

// Protected Routes (Butuh Sanctum Bearer Token)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);

    // Dashboard
    Route::get('/dashboard/summary', [DashboardController::class, 'summary']);

    // Tasks API
    Route::apiResource('tasks', TaskController::class);

    // Assets API
    Route::apiResource('assets', AssetController::class);

    // Team Members API
    Route::get('/team/members', [TeamController::class, 'members']);
});