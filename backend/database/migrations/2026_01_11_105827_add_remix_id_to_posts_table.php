<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{

    public function up(): void
    {
        Schema::table('posts', function (Blueprint $table) {
            // 리믹스 추천글이 아닐 수도 있으므로 nullable()을 붙입니다.
            $table->foreignId('remix_id')->nullable()->constrained()->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::table('posts', function (Blueprint $table) {
            $table->dropForeign(['remix_id']);
            $table->dropColumn('remix_id');
        });
    }
};
