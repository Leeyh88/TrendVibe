<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\FavoriteTrack;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;

class FavoriteController extends Controller
{
    public function index()
    {
        $user = auth()->user();

        // 유튜브 트렌드 관심곡 (type: youtube)
        $youtubeFavorites = $user->favoriteTracks()
            ->where('type', 'youtube')
            ->latest()
            ->get();

        // 리믹스 관심곡 (type: remix)
        $remixFavorites = $user->favoriteTracks()
                ->where('favorite_tracks.type', 'remix')
                ->join('remixes', 'favorite_tracks.track_id', '=', 'remixes.id')
                ->join('users', 'remixes.user_id', '=', 'users.id')
                ->select(
                    'favorite_tracks.id as favorite_id',
                    'favorite_tracks.track_id',
                    'remixes.title as remix_title',
                    'remixes.youtube_video_id', // 리믹스 영상 ID
                    'users.name as artist_name',  // 조인한 유저 정보
                    'users.id as artist_id',       // 프로필 이동용 ID
                    'remixes.track_title as remix_track_title',
                    'remixes.artist_name as remix_artist_name',
                    'users.id as user_id'
                )
                ->latest('favorite_tracks.created_at')
                ->get();

        // 유저가 업로드한 리믹스 (득표카운트, 좋아요카운트)
        $myRemixes = $user->remixes()
            ->select('id', 'title', 'youtube_video_id', 'view_count', 'created_at')
            // 1. 승리 횟수(winLogs)와 2. 관심곡 등록 횟수(favoritedBy)를 동시에 카운트
            ->withCount(['winLogs', 'favoritedBy']) 
            ->latest()
            ->get()
            ->map(function ($remix) {
                return [
                    'id' => $remix->id,
                    'title' => $remix->title,
                    'youtube_video_id' => $remix->youtube_video_id,
                    'view_count' => number_format($remix->view_count),
                    'vote_count' => number_format($remix->win_logs_count), // 배틀 승리수
                    'favorite_count' => number_format($remix->favorited_by_count), // 받은 좋아요수
                    'created_at_human' => $remix->created_at->diffForHumans(),
                ];
            });

        return Inertia::render('Favorites/Index', [
            'youtubeFavorites' => $youtubeFavorites,
            'remixFavorites' => $remixFavorites,
            'myRemixes' => $myRemixes
        ]);
    }

    public function toggle(Request $request)
    {
        $request->validate([
            'track_id' => 'required',
            'type' => 'required|in:youtube,remix',
            'title' => 'required',
        ]);

        $user = auth()->user();

        $favorite = FavoriteTrack::where('user_id', $user->id)
        ->where('track_id', $request->track_id)
        ->where('type', $request->type)
        ->first();

        if ($favorite) {
            $favorite->delete();
            return response()->json(['message' => 'removed', 'isFavorite' => false]);
        }

        FavoriteTrack::create([
            'user_id' => $user->id,
            'track_id' => $request->track_id,
            'type' => $request->type,
            'title' => $request->title,
            'thumbnail' => $request->thumbnail,
        ]);

        return response()->json(['message' => 'added', 'isFavorite' => true]);
    }
    
}
