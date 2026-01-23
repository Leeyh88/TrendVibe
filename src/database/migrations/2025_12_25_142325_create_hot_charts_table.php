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
        Schema::create('hot_charts', function (Blueprint $table) {
            $table->id();
            $table->string('platform'); // youtube, melon, spotify, apple
            $table->integer('rank');
            $table->string('title');
            $table->string('artist');
            $table->string('external_url');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('hot_charts');
    }
};
