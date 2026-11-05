<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserDeviceToken extends Model
{
    protected $table = 'user_device_tokens';

    protected $fillable = [
        'user_id',
        'device_token',
        'platform',
        'device_name',
        'last_seen_at',
    ];

    protected $casts = [
        'last_seen_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
