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
    if (!Schema::hasTable('contacts')) {
        Schema::create('contacts', function (Blueprint $table) {
            $table->id();
            $table->string('email'); // 회신받을 이메일
            $table->text('message'); // 문의 내용
            $table->boolean('is_read')->default(false); // 읽음 처리 여부 (나중에 어드민용)
            $table->timestamps(); // 작성일자
        });
    }
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('contacts');
    }
};
