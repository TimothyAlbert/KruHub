<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;

class TeamController extends Controller
{
    public function members(Request $request)
    {
        $members = User::where('team_id', $request->user()->team_id)
            ->select('id', 'name', 'email', 'role', 'division')
            ->get();

        return response()->json($members);
    }
}