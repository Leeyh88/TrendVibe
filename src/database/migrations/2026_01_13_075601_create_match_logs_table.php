<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
    {
        Schema::create('match_logs', function (Blueprint $table) {
            $table->id();
            // 승리한 리믹스 ID
            $table->foreignId('winner_id')->constrained('remixes')->onDelete('cascade'); 
            // 패배한 리믹스 ID
            $table->foreignId('loser_id')->constrained('remixes')->onDelete('cascade');
            // 투표한 유저 ID (로그인하지 않은 유저도 고려한다면)
            $table->foreignId('user_id')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('match_logs');
    }
};
