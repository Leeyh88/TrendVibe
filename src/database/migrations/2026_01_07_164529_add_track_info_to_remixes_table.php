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
        Schema::table('remixes', function (Blueprint $table) {
            // 원곡 제목, 가수, 앨범 커버 URL 추가
            $table->string('track_title')->nullable()->after('id');
            $table->string('artist_name')->nullable()->after('track_title');
            $table->string('album_cover_url')->nullable()->after('artist_name');
            
            // iTunes 고유 ID (중복 등록 방지나 나중에 API 재호출 시 유용)
            $table->string('itunes_track_id')->nullable()->after('album_cover_url');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('remixes', function (Blueprint $table) {
            $table->dropColumn(['track_title', 'artist_name', 'album_cover_url', 'itunes_track_id']);
        });
    }
};
