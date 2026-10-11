<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tasks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('team_id')->constrained('teams')->cascadeOnDelete();
            $table->string('title');
            $table->string('division');
            $table->enum('status', ['In Progress', 'Review', 'Blocked', 'Completed'])->default('In Progress');
            $table->date('deadline_date')->nullable();
            $table->foreignId('created_by')->constrained('users');
            $table->timestamps();
            $table->softDeletes(); // Audit Trail
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tasks');
    }
};
