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
        Schema::create('worldcups', function (Blueprint $table) {
            $table->id();
            $table->string('title'); // 예: 2024년 12월 최고의 EDM 리믹스
            $table->enum('status', ['active', 'finished'])->default('active'); // 진행 상태
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('worldcups');
    }
};
