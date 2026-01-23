<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\MusicTrack;

class MusicTrackSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        \App\Models\MusicTrack::create([
            'id' => 1,
            'title' => 'Magnetic',
            'artist' => 'ILLIT',
            'thumbnail_url' => 'https://example.com/thumb1.jpg'
        ]);
        
        \App\Models\MusicTrack::create([
            'id' => 2,
            'title' => 'Supernova',
            'artist' => 'aespa',
            'thumbnail_url' => 'https://example.com/thumb2.jpg'
        ]);
    }
}
