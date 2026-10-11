<?php

namespace App\Http\Controllers;

use App\Models\Asset;
use App\Models\Task;
use App\Models\User;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function summary(Request $request)
    {
        $teamId = $request->user()->team_id;

        $tasks = Task::where('team_id', $teamId)->get();
        $assets = Asset::where('team_id', $teamId)->get();
        $membersCount = User::where('team_id', $teamId)->count();

        return response()->json([
            'total_tasks' => $tasks->count(),
            'completed_tasks' => $tasks->where('status', 'Completed')->count(),
            'pending_tasks' => $tasks->whereIn('status', ['In Progress', 'Review'])->count(),
            'blocked_tasks' => $tasks->where('status', 'Blocked')->count(),
            'total_assets' => $assets->count(),
            'available_assets' => $assets->where('status', 'Available')->count(),
            'in_use_assets' => $assets->where('status', 'In Use')->count(),
            'maintenance_assets' => $assets->where('status', 'Maintenance')->count(),
            'total_team_members' => $membersCount,
        ]);
    }
}