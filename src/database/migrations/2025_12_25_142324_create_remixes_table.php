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
        Schema::create('remixes', function (Blueprint $table) {
            $table->id();
            // 외래키 설정: constrained()는 해당 테이블의 id를 자동으로 참조합니다.
            $table->foreignId('music_track_id')->constrained()->onDelete('cascade');
            $table->foreignId('genre_id')->constrained()->onDelete('cascade');
            
            // 작성자 (나중에 User 테이블과 연결되겠지만 일단 컬럼 생성)
            $table->foreignId('user_id')->nullable(); 

            $table->string('title');             // 리믹스 게시물 제목
            $table->string('youtube_url');       // 유튜브 링크
            $table->string('youtube_video_id');  // 유튜브 고유 ID
            $table->text('description')->nullable(); // 곡 설명
            
            $table->unsignedInteger('view_count')->default(0); // 조회수
            $table->unsignedInteger('vote_count')->default(0); // 투표수
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('remixes');
    }
};
