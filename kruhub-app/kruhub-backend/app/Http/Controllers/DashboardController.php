<?php

namespace App\Http\Controllers;

use App\Models\Asset;
use App\Models\Task;
use App\Models\Team;
use App\Models\User;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function summary(Request $request)
    {
        // Ambil Project ID dari header X-Project-ID
        $teamId = $request->header('X-Project-ID');

        if (!$teamId) {
            return response()->json([
                'total_tasks' => 0,
                'completed_tasks' => 0,
                'pending_tasks' => 0,
                'blocked_tasks' => 0,
                'total_assets' => 0,
                'available_assets' => 0,
                'in_use_assets' => 0,
                'maintenance_assets' => 0,
                'total_team_members' => 0,
            ]);
        }

        $tasks = Task::where('team_id', $teamId)->get();
        $assets = Asset::where('team_id', $teamId)->get();

        // Menghitung anggota yang tergabung di team ini via pivot team_user
        $membersCount = User::whereHas('teams', function ($q) use ($teamId) {
            $q->where('teams.id', $teamId);
        })->count();

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

    public function adminDashboard()
    {
        $stats = [
            'total_projects' => Team::count(),
            'active_projects' => Team::where('project_status', 'Active')->count(),
            'total_members' => User::count(),
            'total_tasks' => Task::count(),
            'completed_tasks' => Task::where('status', 'Completed')->count(),
            'pending_tasks' => Task::whereIn('status', ['In Progress', 'Review'])->count(),
            'total_assets' => Asset::count(),
            'available_assets' => Asset::where('status', 'Available')->count(),
            'maintenance_assets' => Asset::where('status', 'Maintenance')->count(),
        ];

        $projects = Team::withCount('members')
            ->orderByDesc('updated_at')
            ->take(5)
            ->get();

        $recentTasks = Task::with('team')
            ->orderByDesc('updated_at')
            ->take(5)
            ->get();

        $recentAssets = Asset::with('team')
            ->orderByDesc('updated_at')
            ->take(5)
            ->get();

        return view('admin.dashboard', compact('stats', 'projects', 'recentTasks', 'recentAssets'));
    }
}