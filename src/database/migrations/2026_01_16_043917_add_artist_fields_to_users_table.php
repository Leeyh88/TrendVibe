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
        Schema::table('users', function (Blueprint $table) {
            // 포인트 (기본값 0)
            $table->integer('points')->default(0)->after('email'); 
            
            // 아티스트 소셜 정보
            $table->string('soundcloud_url')->nullable()->after('points');
            $table->string('youtube_url')->nullable()->after('soundcloud_url');
            
            // 후원 및 자기소개
            $table->text('donation_info')->nullable()->after('youtube_url');
            $table->text('bio')->nullable()->after('donation_info');
            
            // 활동 정보 (사용 DAW 등)
            $table->string('daw_info')->nullable()->after('bio');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'points',
                'soundcloud_url',
                'youtube_url',
                'donation_info',
                'bio',
                'daw_info'
            ]);
        });
    }
};