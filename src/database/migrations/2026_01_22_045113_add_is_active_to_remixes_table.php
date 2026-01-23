<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('remixes', function (Blueprint $table) {
            // 기본값은 노출(true)로 설정합니다.
            $table->boolean('is_active')->default(true)->after('vote_count');
        });
    }

    public function down()
    {
        Schema::table('remixes', function (Blueprint $table) {
            $table->dropColumn('is_active');
        });
    }
};
