<?php

namespace Database\Seeders;

use App\Models\Genre;
use Illuminate\Database\Seeder;

class GenreSeeder extends Seeder
{
    public function run(): void
    {
        // 리믹스 데이터가 genre_id: 1을 참조하고 있으므로, 순서대로 생성합니다.
        Genre::create(['name' => 'EDM', 'slug' => 'edm']);      // ID: 1
        Genre::create(['name' => 'Lo-fi', 'slug' => 'lo-fi']);  // ID: 2
        Genre::create(['name' => 'Hiphop', 'slug' => 'hiphop']); // ID: 3
        Genre::create(['name' => 'K-Pop', 'slug' => 'k-pop']);
    }
}