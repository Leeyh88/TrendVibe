<?php

namespace App\Http\Controllers;

use App\Models\Trend;
use Inertia\Inertia;
use Illuminate\Http\Request;

class TrendsController extends Controller
{
    public function index()
    {
        // 1. 유저 관심곡 ID 가져오기
        $userFavoriteIds = [];
        if (auth()->check()) {
            $userFavoriteIds = auth()->user()->favoriteTracks()
                ->pluck('track_id')
                ->toArray();
        }

        $charts = [];

        // 2. 유튜브 데이터 로드
        $categories = ['kr_songs', 'us_songs', 'kr_trend', 'us_trend'];
        foreach ($categories as $category) {
            $charts["youtube_{$category}"] = Trend::where('platform', 'youtube')
                ->where('category', $category)
                ->orderBy('rank')
                ->get()
                ->map(function ($trend) use ($userFavoriteIds) {
                    $trend->isFavorite = in_array((string)$trend->external_id, $userFavoriteIds);
                    $trend->youtube_video_id = $trend->external_id;
                    return $trend;
                });
        }

        // 3. 스포티파이 데이터 로드
        $s_categories = ['Global', 'Korea'];
        foreach ($s_categories as $s_category) {
            $charts["spotify_{$s_category}"] = Trend::where('platform', 'Spotify')
                ->where('category', $s_category)
                ->orderBy('rank')
                ->get()
                ->map(function ($trend) use ($userFavoriteIds) {
                    $trend->isFavorite = in_array((string)$trend->external_id, $userFavoriteIds);
                    // 스포티파이는 보통 youtube_video_id가 없으므로 null 처리
                    $trend->youtube_video_id = null; 
                    return $trend;
                });
        }

        // 4. 사운드클라우드 빈 배열
        $charts['soundcloud'] = [];

        return Inertia::render('Trends/Index', [
            'charts' => $charts,
        ]);
    }
}