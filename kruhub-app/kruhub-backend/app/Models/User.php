<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'division',
        'division_id',
        'position',
        'phone',
        'bio',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    public function division()
    {
        return $this->belongsTo(Division::class);
    }

    public function teams()
    {
        return $this->belongsToMany(Team::class, 'team_user')
            ->withPivot('role')
            ->withTimestamps();
    }

    public function ownedTeams()
    {
        return $this->hasMany(Team::class, 'owner_id');
    }

    public function isProjectOwner(?Team $team = null): bool
    {
        if ($team === null) {
            return false;
        }

        return (int) $team->owner_id === (int) $this->id || $team->members()
            ->where('users.id', $this->id)
            ->wherePivot('role', 'owner')
            ->exists();
    }

    public function isProjectLead(?Team $team = null): bool
    {
        if ($team === null) {
            return false;
        }

        return $team->members()
            ->where('users.id', $this->id)
            ->wherePivot('role', 'project_lead')
            ->exists();
    }

    public function isDivisionLead(?Team $team = null): bool
    {
        if ($team === null) {
            return false;
        }

        return $team->members()
            ->where('users.id', $this->id)
            ->wherePivot('role', 'division_lead')
            ->exists();
    }
}