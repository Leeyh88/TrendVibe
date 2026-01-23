<?php
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\RemixController;
use Illuminate\Support\Facades\DB;
use App\Models\Genre;

Route::middleware(['web', 'auth'])->group(function() {
    Route::post('/remixes/{id}/vote', [\App\Http\Controllers\RemixController::class, 'vote']);
});

Route::get('/remixes', [RemixController::class, 'index']);
Route::get('/genres', function() {
    return Genre::all();
});