<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('team_user', function (Blueprint $table) {
            $table->id();
            
            // Relasi Foreign Key ke tabel teams
            $table->foreignId('team_id')
                  ->constrained()
                  ->onDelete('cascade');
                  
            // Relasi Foreign Key ke tabel users
            $table->foreignId('user_id')
                  ->constrained()
                  ->onDelete('cascade');
                  
            // Kolom opsional untuk peran anggota di dalam tim (misal: Owner, Member, Designer)
            $table->string('role')->default('member');
            
            $table->timestamps();

            // Mencegah duplikasi entri anggota dalam tim yang sama
            $table->unique(['team_id', 'user_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('team_user');
    }
};