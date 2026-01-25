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
        Schema::create('comments', function (Blueprint $table) {
            $table->id();
            // foreignId를 쓰면 관계 설정과 인덱스가 자동으로 잡힙니다.
            $table->foreignId('user_id')->constrained()->onDelete('cascade'); // 작성자 (삭제 시 댓글도 삭제)
            $table->foreignId('post_id')->constrained()->onDelete('cascade'); // 해당 게시글
            $table->text('content'); // 댓글 내용
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('comments');
    }
};
