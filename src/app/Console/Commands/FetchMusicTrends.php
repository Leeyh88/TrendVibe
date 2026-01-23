<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Trend;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FetchMusicTrends extends Command
{
    // 터미널에서 실행할 명령어 이름
    protected $signature = 'trends:fetch';
    protected $description = 'YouTube API를 통해 인기 음악 및 MV 데이터를 수집합니다.';

    public function handle()
    {
        $this->info('트렌드 수집 작업을 시작합니다...');

        // 수집할 리스트
        $tasks = [
            ['category' => 'kr_songs', 'region' => 'KR', 'videoCat' => '10'], // 한국 인기 음악
            ['category' => 'kr_trend', 'region' => 'KR', 'videoCat' => null], // 한국 인기 급상승 영상 
            ['category' => 'us_songs', 'region' => 'US', 'videoCat' => '10'], // 미국 인기 음악
            ['category' => 'us_trend', 'region' => 'US', 'videoCat' => null], // 미국 인기 급상승 영상
        ];

       foreach ($tasks as $task) {
            $this->fetchYoutubeData($task['category'], $task['region'], $task['videoCat']);
        }

        $this->info('모든 데이터 수집이 완료되었습니다!');
    }

    private function fetchYoutubeData($category, $region, $videoCat)
    {
        $this->line("-> {$region} 지역 {$category} 수집 중...");

        $response = Http::get("https://www.googleapis.com/youtube/v3/videos", [
            'part' => 'snippet',
            'chart' => 'mostPopular',
            'regionCode' => $region,
            'videoCategoryId' => $videoCat,
            'maxResults' => 10,
            'key' => config('services.youtube.key'),
        ]);

        if ($response->successful()) {
            foreach ($response->json()['items'] as $index => $item) {
                Trend::updateOrCreate(
                    [
                        'platform' => 'youtube',
                        'category' => $category, // 'kr_songs', 'us_songs' 등으로 저장
                        'rank' => $index + 1,
                    ],
                    [
                        'title' => $item['snippet']['title'],
                        'artist' => $item['snippet']['channelTitle'],
                        'album_cover_url' => $item['snippet']['thumbnails']['high']['url'],
                        'external_id' => $item['id'],
                    ]
                );
            }
        } else {
            $this->error("   [에러] {$region} 데이터 수집 실패");
        }
    }
}