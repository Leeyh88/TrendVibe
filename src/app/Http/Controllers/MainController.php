<?php

namespace App\Http\Controllers;

use App\Models\Post;
use App\Models\Remix;
use App\Models\FavoriteTrack;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Illuminate\Support\Facades\DB;

class MainController extends Controller
{
    public function index()
    {
        // 1. 현재 로그인한 유저의 관심곡 목록 가져오기 (track_id 컬럼의 값들을 배열로 추출)
        $userFavoriteIds = [];
        if (auth()->check()) {
            $userFavoriteIds = auth()->user()->favoriteTracks()->pluck('track_id')->toArray();
        }

        // 2. Hot Trends: 유튜브 기반 (track_id가 youtube_video_id로 저장됨)
        $hotTrends = Remix::select('track_title', 'artist_name', 'album_cover_url', 'youtube_video_id', DB::raw('count(*) as total'))
            ->groupBy('track_title', 'artist_name', 'album_cover_url', 'youtube_video_id')
            ->orderByDesc('total')
            ->take(4)
            ->get()
            ->map(function ($trend) use ($userFavoriteIds) {
                // 관심곡 목록에 실제 youtube_video_id가 있는지 확인
                $trend->isFavorite = in_array($trend->youtube_video_id, $userFavoriteIds);
                return $trend;
            });

        // 3. Leaderboard: 리믹스 DB 기반 (track_id가 remix의 id로 저장됨)
        $leaderboard = Remix::with('user')
            ->orderByDesc('vote_count')
            ->take(5)
            ->get()
            ->map(function ($remix) use ($userFavoriteIds) {
                // DB의 id(숫자)를 문자열로 변환하여 관심곡 목록(track_id 배열)과 대조
                $remix->isFavorite = in_array((string)$remix->id, $userFavoriteIds);
                return $remix;
            });

        // 4. Latest Feedback
        $latestFeedback = Post::with(['user', 'remix'])
            ->latest()
            ->take(5)
            ->get();

        return Inertia::render('Welcome', [
            'hotTrends' => $hotTrends,
            'latestFeedback' => $latestFeedback,
            'leaderboard' => $leaderboard,
        ]);
    }
}