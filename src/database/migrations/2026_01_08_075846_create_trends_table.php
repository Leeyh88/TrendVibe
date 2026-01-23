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
        Schema::create('trends', function (Blueprint $table) {
            $table->id();
            $table->string('platform'); // youtube, spotify, melon
            $table->string('category'); // top_songs, top_mvs
            $table->integer('rank');
            $table->string('title');
            $table->string('artist');
            $table->string('album_cover_url')->nullable();
            $table->string('external_id')->nullable(); // 유튜브 영상 ID 등
            $table->timestamps();
            
            // 검색 성능을 위해 복합 인덱스 설정
            $table->index(['platform', 'category']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('trends');
    }
};
