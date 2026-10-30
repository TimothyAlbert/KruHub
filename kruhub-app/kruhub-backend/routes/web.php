<?php

use App\Http\Controllers\DashboardController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/admin', [DashboardController::class, 'adminDashboard']);
Route::get('/admin/dashboard', [DashboardController::class, 'adminDashboard']);
