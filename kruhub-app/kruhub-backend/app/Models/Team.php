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
            ->withPivot(['role', 'division_id'])
            ->withTimestamps();
    }

    public function divisions()
    {
        return $this->hasMany(Division::class, 'team_id');
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
        $member = $this->members()->where('users.id', $user->id)->first();

        if (!$member || ($member->pivot->role ?? null) !== 'division_lead') {
            return false;
        }

        if ($division === null) {
            return true;
        }

        $memberDivisionId = $member->pivot?->division_id;
        if (!$memberDivisionId) {
            return false;
        }

        $memberDivision = Division::find($memberDivisionId);

        return strtolower((string) ($memberDivision?->name ?? '')) === strtolower(trim((string) $division));
    }

    public function getUserDivision(User $user): ?string
    {
        $member = $this->members()->where('users.id', $user->id)->first();

        if (!$member || !$member->pivot?->division_id) {
            return null;
        }

        return Division::find($member->pivot->division_id)?->name;
    }

    public function canManageMembers(User $user): bool
    {
        return $this->isOwner($user) || $this->isProjectLead($user);
    }

    public function canManageProjectMember(User $actor, User $member): bool
    {
        if ($this->canManageMembers($actor)) {
            return true;
        }

        if (!$this->isDivisionLead($actor)) {
            return false;
        }

        $actorDivisionId = $this->members()->where('users.id', $actor->id)->first()?->pivot?->division_id;
        $memberDivisionId = $this->members()->where('users.id', $member->id)->first()?->pivot?->division_id;

        return $actorDivisionId !== null && $actorDivisionId === $memberDivisionId;
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

        return (strtolower((string) $this->getUserDivision($user)) === strtolower(trim((string) $division))) || $this->isDivisionLead($user, $division);
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