<?php

namespace App\Http\Controllers;

use App\Http\Requests\ProfileUpdateRequest;
use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Redirect;
use Inertia\Inertia;
use Inertia\Response;
use Illuminate\Support\Facades\Storage; 
use App\Models\User;

class ProfileController extends Controller
{
    public function edit(Request $request): Response
    {
        return Inertia::render('Profile/Edit', [
            'mustVerifyEmail' => $request->user() instanceof MustVerifyEmail,
            'status' => session('status'),

            // 내가 쓴 게시글 최신 5개
            'myPosts' => $request->user()->posts()
            ->withCount(['comments', 'likes'])
            ->latest()
            ->take(5)
            ->get(),

            // 내가 좋아요 누른 게시글 (최신5개)
            'likedPosts' => \App\Models\Post::whereHas('likes', function($q) use ($request) {
                $q->where('user_id', $request->user()->id);
            })
            ->with(['user'])
            ->withCount(['comments', 'likes'])
            ->latest()
            ->take(5)
            ->get(),
        ]);
    }

    

    public function update(ProfileUpdateRequest $request): RedirectResponse
    {
        $user = $request->user();
        
        // 1. 이미지 파일 처리 로직 추가
        if ($request->hasFile('profile_photo')) {
            // 기존 이미지가 있으면 삭제 (서버 용량 절약)
            if ($user->profile_photo_path) {
                Storage::disk('public')->delete($user->profile_photo_path);
            }
            
            // 새 이미지를 'profile-photos' 폴더에 저장하고 경로 반환
            $path = $request->file('profile_photo')->store('profile-photos', 'public');
            
            // 유저 모델의 경로 컬럼 업데이트
            $user->profile_photo_path = $path;
        }

        // 2. 나머지 유효성 검사 통과 데이터(name, public_email 등) 채우기
        $user->fill($request->validated());

        if ($user->isDirty('email')) {
            $user->email_verified_at = null;
        }

        $user->save();

        return Redirect::route('profile.edit');
    }

    public function destroy(Request $request): RedirectResponse
    {
        $request->validate([
            'password' => ['required', 'current_password'],
        ]);

        $user = $request->user();

        Auth::logout();

        $user->delete();

        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return Redirect::to('/');
    }

    public function show(User $user)
    {
        // 0. 팔로워 카운트 로직 제거 (에러 방지)
        // $user->loadCount(['followers', 'followings']); 

        // 1. 해당유저의 리믹스곡 가져오기
         $remixes = \App\Models\Remix::where('user_id', $user->id)
        ->latest()
        ->paginate(10);

        // 2. 해당 유저의 게시글 목록 조회
        // User 모델에 posts() 관계가 정의되어 있어야 합니다.
        $posts = $user->posts()
            ->latest()
            ->paginate(10);

        // 3. 해당 유저의 리믹스 목록 
        $remixes = \App\Models\Remix::where('user_id', $user->id)
        ->latest()
        ->paginate(10); // 10개씩 페이징

        // 4. 해당유저의 리믹스가 추천받은 수
        $totalWins = \DB::table('match_logs')
                ->whereIn('winner_id', function($query) use ($user) {
                    $query->select('id')
                        ->from('remixes')
                        ->where('user_id', $user->id);
                })
                ->count();

        return Inertia::render('Profile/Public', [
            'artist' => [
                'id' => $user->id,
                'name' => $user->name,
                'profile_photo_url' => $user->profile_photo_path ? asset('storage/' . $user->profile_photo_path) : null,
                'bio' => $user->bio,
                'soundcloud_url' => $user->soundcloud_url,
                'youtube_url' => $user->youtube_url,
                'daw_info' => $user->daw_info,
                'donation_info' => $user->donation_info,
                'public_email' => $user->public_email,
                'total_likes' => $totalWins,
                // 팔로워 기능은 나중에 추가할 예정이므로 0
                'followers_count' => 0,
                'followings_count' => 0,
                'is_following' => false,
            ],
            'posts' => $posts,
            'remixes' => $remixes,
        ]);
    }
}
