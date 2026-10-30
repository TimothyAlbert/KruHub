<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Asset extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'team_id',
        'name',
        'category',
        'division',
        'location',
        'status',
        'approval_status',
        'approved_by',
        'related_task_id',
        'description',
        'created_by',
    ];

    public function team()
    {
        return $this->belongsTo(Team::class);
    }

    public function task()
    {
        return $this->belongsTo(Task::class, 'related_task_id');
    }

    public function approver()
    {
        return $this->belongsTo(User::class, 'approved_by');
    }
}
