<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Team extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'team_code',
        'description',
        'roles',
        'owner_id', // Sesuaikan jika ada kolom owner/user_id
    ];

    protected $casts = [
        'roles' => 'array', // Mengonversi array dari Flutter otomatis menjadi JSON di MySQL
    ];

    public function members()
    {
        return $this->belongsToMany(User::class, 'team_user');
    }
}