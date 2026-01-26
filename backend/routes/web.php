<?php
use App\Models\Genre;
use App\Http\Controllers\ProfileController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PostController;
use App\Http\Controllers\CommentController;
use App\Http\Controllers\ImageController;
use App\Http\Controllers\PostLikeController;
use App\Http\Controllers\RemixController;
use App\Http\Controllers\TrendsController;
use App\Http\Controllers\MainController;
use Illuminate\Http\Request;
use Inertia\Inertia;
use App\Models\Remix;
use App\Models\MatchLog;
use App\Http\Controllers\Auth\GoogleController;
use App\Http\Controllers\SocialController;
use App\Http\Controllers\FavoriteController;
use App\Http\Controllers\ContactController;

// 구글 OAuth
Route::get('auth/google', [GoogleController::class, 'redirectToGoogle'])->name('google.login');
Route::get('auth/google/callback', [GoogleController::class, 'handleGoogleCallback']);

// 카카오 OAuth
Route::get('/auth/kakao', [SocialController::class, 'redirectToKakao']);
Route::get('/auth/kakao/callback', [SocialController::class, 'handleKakaoCallback']);

// 관리자 문의 저장 라우트
Route::post('/contact', [ContactController::class, 'store'])->name('contact.store');

// 메인 페이지
Route::get('/', [MainController::class, 'index'])->name('home');

// 순위 페이지
Route::get('/rankings', function (Request $request) {
    // 정렬 기준 설정 (기존 로직 유지)
    $sort = $request->query('sort', 'votes');
    $column = ($sort === 'views') ? 'view_count' : 'vote_count';

    $userFavoriteIds = [];
    if (auth()->check()) {
        $userFavoriteIds = auth()->user()->favoriteTracks()
            ->pluck('track_id')
            ->toArray();
    }

    // 실시간 통계 데이터 계산 (추가된 부분)
    $stats = [
        // 전체 리믹스 곡의 누적 승리(점수) 합계
        'total_points' => number_format(Remix::sum('vote_count')),
        // 현재 DB에 등록된 총 리믹스 곡 수
        'total_remixes' => number_format(Remix::count()),
    ];

    // 3. 랭킹 데이터 조회
    $rankings = Remix::with(['user', 'genre', 'musicTrack'])
        ->orderBy($column, 'desc')
        ->take(20) // 10개는 조금 적을 수 있어 20개로 늘렸습니다.
        ->get()
        ->map(function ($remix) use ($userFavoriteIds) {
            $remix->isFavorite = in_array((string)$remix->id, $userFavoriteIds);
            return $remix;
        });

    return Inertia::render('Rankings/Index', [
        'rankings' => $rankings,
        'currentSort' => $sort,
        'stats' => $stats, // ✅ 프론트엔드로 통계 전달
        // 만약 장르 필터나 검색 기능이 필요하다면 아래도 함께 보냅니다.
        'genres' => Genre::all(), 
        'filters' => $request->only(['sort'])
    ]);
})->name('rankings');

// 믹스매치 페이지
Route::get('/mix-match', function () {

    $userFavoriteIds = auth()->check() ? auth()->user()->favoriteTracks()->pluck('track_id')->toArray() : [];

    $candidates = Remix::with(['musicTrack', 'genre', 'user']) // <-- 여기 user 추가
        ->inRandomOrder()
        ->take(2)
        ->get()
        ->map(function ($remix) use ($userFavoriteIds) {
            // ID 타입 일관성을 위해 (string) 캐스팅 유지
            $remix->isFavorite = in_array((string)$remix->id, $userFavoriteIds);
            return $remix;
        });

    return Inertia::render('Worldcup/Index', [
        'candidates' => $candidates
    ]);
})->name('mixmatch');

// 게시판 (index, show ) 공개접근
Route::get('posts', [PostController::class, 'index'])->name('posts.index');
Route::get('posts/{post}', [PostController::class, 'show'])->name('posts.show')->where('post', '[0-9]+');

// 핫 트렌드 (외부 API 연동 예정)
Route::get('/trends', [TrendsController::class, 'index'])->name('trends');

// 리믹스
Route::get('/remixes', [RemixController::class, 'index'])->name('remixes.index');

// 로그인한 사용자만 접근 가능한 메뉴들
Route::middleware(['auth'])->group(function () {
    // 관심곡 (핫트렌드, 리믹스)
    Route::post('/favorites/toggle', [FavoriteController::class, 'toggle'])->name('favorites.toggle');

    // 게시판 전체 기능 (index, create, store, show 등) 자동 매핑
    Route::resource('posts', PostController::class)->except(['index','show']);

     // 믹스매치 투표(선택) 처리 로직
    Route::post('/worldcup/{id}/vote', function (Request $request,$id) {
        // 1. 선택된 곡을 DB에서 찾습니다.
        $remix = Remix::findOrFail($id);

        // 2. 투표수(vote_count)를 1 올립니다.
        $remix->increment('vote_count');

        // 3. 로그 기록
        $winnerId = $id;
        $loserId = $request->input('loser_id');

        MatchLog::create([
            'winner_id' => $winnerId,
            'loser_id' => $loserId,
            'user_id' => auth()->id(),
        ]);

        return back(); 
    })->name('worldcup.vote');

    // 게시판 댓글 작성
    Route::post('posts/{post}/comments', [CommentController::class, 'store'])->name('posts.comments.store');
    // 게시판 댓글 삭제
    Route::delete('comments/{comment}', [CommentController::class, 'destroy'])->name('comments.destroy');
    // 게시판 이미지 업로드
    Route::post('/upload-image', [ImageController::class, 'store'])->name('image.upload');
    // 게시판 좋아요
    Route::post('/posts/{post}/like', [PostLikeController::class, 'store'])->name('posts.like')->middleware('auth');

    
    Route::get('/remixes/create', [RemixController::class, 'create'])->name('remixes.create');
    Route::post('/remixes', [RemixController::class, 'store'])->name('remixes.store');

    Route::get('/my-vibe', [FavoriteController::class, 'index'])->name('favorites.index')->middleware('auth');

    // 프로필
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');

    // 공개 프로필
    Route::get('/public-profile/{user}', [ProfileController::class, 'show'])->name('profile.public');
});

require __DIR__.'/auth.php';
