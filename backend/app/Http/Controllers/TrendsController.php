<?php
namespace App\Http\Controllers;
use App\Models\Trend;
use Inertia\Inertia;

class TrendsController extends Controller
{

    public function index()
    {
        // 1. 현재 로그인한 유저의 관심곡(유튜브 타입) ID 목록 가져오기
        $userFavoriteIds = [];
        if (auth()->check()) {
            $userFavoriteIds = auth()->user()->favoriteTracks()
                ->where('type', 'youtube')
                ->pluck('track_id')
                ->toArray();
        }

        // 2. 유튜브, 스포티파이 데이터 로드 및 관심곡 여부 매핑
        $categories = ['kr_songs', 'us_songs', 'kr_trend', 'us_trend'];
        $s_categories = ['Global','Korea'];
        $charts = [];

        foreach ($categories as $category) {
            $charts["youtube_{$category}"] = Trend::where('platform', 'youtube')
                ->where('category', $category)
                ->orderBy('rank')
                ->get()
                ->map(function ($trend) use ($userFavoriteIds) {
                    // DB의 external_id(유튜브비디오ID)가 유저의 관심곡 목록에 있는지 확인
                    $trend->isFavorite = in_array((string)$trend->external_id, $userFavoriteIds);
                    // 프론트엔드 selectedSong 규격에 맞게 youtube_video_id 필드 추가 (선택사항)
                    $trend->youtube_video_id = $trend->external_id;
                    return $trend;
                });
        }
        
        foreach ($s_categories as $s_category) {
            $charts["spotify_{$s_category}"] = Trend::where('platform', 'Spotify')
                ->where('category', $s_category)
                ->orderBy('rank')
                ->get()
                ->map(function ($trend) use ($userFavoriteIds) {
                    // 스포티파이 고유 ID(external_id)가 관심곡에 있는지 확인
                    $trend->isFavorite = in_array((string)$trend->external_id, $userFavoriteIds);
                    return $trend;
                });
        }


        // 3. 사운드클라우드 빈 배열 유지
        $charts['soundcloud'] = [];

        return Inertia::render('Trends/Index', [
            'charts' => $charts,
        ]);
    }
}
