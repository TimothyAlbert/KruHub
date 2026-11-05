<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Division extends Model
{
    use HasFactory;

    protected $fillable = [
        'team_id',
        'name',
        'slug',
        'description',
    ];

    public function team()
    {
        return $this->belongsTo(Team::class);
    }

    public function users()
    {
        return $this->hasMany(User::class);
    }
}
