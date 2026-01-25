<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Remix;

class RemixSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $data = [
            [
            'music_track_id' => 1,
            'genre_id' => 1,
            'title' => 'EDM 스타일 리믹스',
            'youtube_url' => 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 
            'youtube_video_id' => 'dQw4w9WgXcQ',
            'view_count' => 150,
            ],
            [
                'music_track_id' => 1,
                'genre_id' => 2,
                'title' => '로파이(Lo-fi) 힙합 버전',
                'youtube_url' => 'https://www.youtube.com/watch?v=jfKfPfyJRdk', 
                'youtube_video_id' => 'jfKfPfyJRdk',
                'view_count' => 2400,
            ],
            [
                'music_track_id' => 1,
                'genre_id' => 1,
                'title' => '파워풀한 베이스 리믹스',
                'youtube_url' => 'https://www.youtube.com/watch?v=9bZkp7q19f0', 
                'youtube_video_id' => '9bZkp7q19f0',
                'view_count' => 890,
            ],
        ];

        foreach ($data as $item) {
            \App\Models\Remix::create($item);
        }
    }
}
