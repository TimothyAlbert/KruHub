<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MemberPermission extends Model
{
    use HasFactory;

    protected $fillable = [
        'team_id',
        'user_id',
        'tab',
        'can_read',
        'can_create',
        'can_update',
        'can_delete',
    ];

    public function team()
    {
        return $this->belongsTo(Team::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
