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
        Schema::create('worldcup_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('worldcup_id')->constrained()->onDelete('cascade');
            $table->foreignId('remix_id')->constrained()->onDelete('cascade');
            $table->unsignedInteger('win_count')->default(0); // 최종 우승 횟수
            $table->unsignedInteger('match_count')->default(0); // 대결 횟수
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('worldcup_items');
    }
};
