<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    // database/migrations/xxxx_xx_xx_create_analyses_table.php

    public function up()
    {
        Schema::create('analyses', function (Blueprint $table) {
            $table->id();
            $table->string('status')->default('pending'); // pending, processing, completed, failed
            $table->string('file_path')->nullable();      // 원본 MIDI 파일 경로
            $table->json('harmony_scores')->nullable();   // [95, 42, 88...] 배열 저장
            $table->json('timeline_labels')->nullable();  // ["00:00", "00:15"...] 배열 저장
            $table->text('ai_comment')->nullable();       // AI가 작성한 분석 리포트 전문
            $table->integer('bpm')->nullable();
            $table->integer('tracks')->nullable();
            $table->float('duration')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('analyses');
    }
};
