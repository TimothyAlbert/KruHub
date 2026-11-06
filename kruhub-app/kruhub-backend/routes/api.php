<?php

use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\AssetController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\TaskController;
use App\Http\Controllers\TeamController;
use Illuminate\Support\Facades\Route;

// Public Routes
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

// Protected Routes (Butuh Sanctum Bearer Token)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/notifications/register-device-token', [AuthController::class, 'registerDeviceToken']);
    Route::delete('/notifications/device-token/{token}', [AuthController::class, 'removeDeviceToken']);
    Route::post('/notifications/send', [NotificationController::class, 'send']);
    Route::get('/user', [AuthController::class, 'user']);
    Route::get('/admin/users', [AuthController::class, 'allUsers']);
    Route::post('/admin/users', [AuthController::class, 'createUser']);
    Route::get('/admin/users/{user}', [AuthController::class, 'showUser']);
    Route::put('/admin/users/{user}', [AuthController::class, 'updateUser']);
    Route::delete('/admin/users/{user}', [AuthController::class, 'deleteUser']);

    // Teams / Projects API
    Route::get('/user/teams', [TeamController::class, 'userTeams']);
    Route::post('/teams', [TeamController::class, 'store']);
    Route::get('/team', [TeamController::class, 'show']);
    Route::put('/team', [TeamController::class, 'update']);
    Route::get('/teams/{team}', [TeamController::class, 'show']);
    Route::put('/teams/{team}', [TeamController::class, 'update']);
    Route::post('/teams/join', [TeamController::class, 'join']);
    Route::get('/team/members', [TeamController::class, 'members']);
    Route::put('/team/members/{userId}', [TeamController::class, 'updateMember']);
    Route::delete('/team/members/{userId}', [TeamController::class, 'removeMember']);

    // Dashboard Summary
    Route::get('/dashboard/summary', [DashboardController::class, 'summary']);

    // Tasks API
    Route::apiResource('tasks', TaskController::class);
    Route::patch('/tasks/{id}/approve', [TaskController::class, 'approve']);

    // Assets API
    Route::get('/assets', [AssetController::class, 'index']);
    Route::post('/assets', [AssetController::class, 'store']);
    Route::get('/assets/{id}', [AssetController::class, 'show']);
    Route::put('/assets/{id}', [AssetController::class, 'update']);
    Route::delete('/assets/{id}', [AssetController::class, 'destroy']);
    Route::patch('/assets/{id}/approve', [AssetController::class, 'approve']);
});