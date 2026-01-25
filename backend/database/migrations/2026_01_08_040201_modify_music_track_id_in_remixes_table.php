<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('remixes', function (Blueprint $table) {
            // 기존 외래키 제약조건이 있다면 먼저 삭제 (이름은 관례에 따라 달라질 수 있음)
            // 만약 외래키 설정을 안했다면 이 줄은 생략 가능합니다.
            // $table->dropForeign(['music_track_id']); 

            // 컬럼을 nullable로 변경
            $table->unsignedBigInteger('music_track_id')->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('remixes', function (Blueprint $table) {
            $table->unsignedBigInteger('music_track_id')->nullable(false)->change();
        });
    }
};
