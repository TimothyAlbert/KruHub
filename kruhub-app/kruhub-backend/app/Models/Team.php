<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class Team extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'name',
        'team_code',
        'description',
        'project_type',
        'project_status',
        'client_name',
        'budget',
        'start_date',
        'end_date',
        'location',
        'objective',
        'scope',
        'owner_id',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
    ];

    public function members()
    {
        return $this->belongsToMany(User::class, 'team_user')
            ->withPivot('role')
            ->withTimestamps();
    }

    public function owner()
    {
        return $this->belongsTo(User::class, 'owner_id');
    }

    public function projectLead()
    {
        return $this->belongsToMany(User::class, 'team_user')
            ->wherePivot('role', 'project_lead')
            ->withTimestamps();
    }

    public function memberRole(User $user): ?string
    {
        return $this->members()
            ->where('users.id', $user->id)
            ->first()?->pivot?->role;
    }

    public function isOwner(User $user): bool
    {
        if ($this->owner_id && (int) $this->owner_id === (int) $user->id) {
            return true;
        }

        return $this->members()
            ->where('users.id', $user->id)
            ->wherePivot('role', 'owner')
            ->exists();
    }

    public function isProjectLead(User $user): bool
    {
        return $this->members()
            ->where('users.id', $user->id)
            ->wherePivot('role', 'project_lead')
            ->exists();
    }

    public function isDivisionLead(User $user, ?string $division = null): bool
    {
        $query = $this->members()
            ->where('users.id', $user->id)
            ->wherePivot('role', 'division_lead');

        if ($division !== null) {
            $query = $query->where('users.division', $division);
        }

        return $query->exists();
    }

    public function canManageMembers(User $user): bool
    {
        return $this->isOwner($user) || $this->isProjectLead($user);
    }

    public function canManageDivision(User $user, ?string $division = null): bool
    {
        if ($this->isOwner($user) || $this->isProjectLead($user)) {
            return true;
        }

        if ($division === null) {
            return false;
        }

        return $this->isDivisionLead($user, $division);
    }

    public function canViewDivision(User $user, ?string $division = null): bool
    {
        if ($this->isOwner($user) || $this->isProjectLead($user)) {
            return true;
        }

        if ($division === null) {
            return true;
        }

        return ($user->division === $division) || $this->isDivisionLead($user, $division);
    }

    public static function generateUniqueTeamCode(): string
    {
        do {
            $letters = strtoupper(Str::substr(Str::random(2), 0, 2));
            $suffix = strtoupper(Str::random(5));
            $code = 'KRU-' . $letters . '-' . $suffix;
        } while (self::where('team_code', $code)->exists());

        return $code;
    }
}