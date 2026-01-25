<?php

namespace App\Http\Controllers;
use App\Models\Post;
use Inertia\Inertia;
use Illuminate\Http\Request;
use App\Models\Remix;
use Carbon\Carbon;

class PostController extends Controller
{
    /**
     * 게시판 목록 조회
     */
    public function index(Request $request)
    {
        // 1. 요청받은 카테고리, 검색어 값 가져오기
        $category = $request->query('category');
        $search = $request->query('search');

        // 통계 데이터 계산
        $boardStats = [
            // 전체 게시글 수
            'totalStories' => number_format(Post::count()),
            // 오늘(현재 날짜 00:00:00 이후) 작성된 게시글 수
            'todayStories' => number_format(Post::where('created_at', '>=', Carbon::today())->count()),
        ];

        return Inertia::render('Posts/Index', [
            'posts' => Post::with('user')
                // 댓글 수와 좋아요 수를 쿼리에 포함
                ->withCount(['comments', 'likes']) 
                // 2. 카테고리가 있으면 해당 카테고리만 필터링
                ->when($category, function ($query, $category) {
                    return $query->where('category', $category);
                })
                // 3. 검색어 필터
                ->when($search, function ($query, $search) {
                    return $query->where(function($q) use ($search) {
                        $q->where('title', 'like', "%{$search}%")
                        ->orWhere('content', 'like', "%{$search}%");
                    });
                })
                ->latest()
                ->paginate(10)
                ->withQueryString(),
            'filters' => [
                'category' => $category,
                'search' => $search
            ],
            'boardStats' => $boardStats
        ]);
    }

    /**
     * 글 쓰기 페이지
     */
    public function create()
    {
        return Inertia::render('Posts/Create', [
            'remixes' => Remix::with('user:id,name') // 작성자 이름 포함
                ->latest()
                ->get([
                    'id', 
                    'user_id',         // user 관계를 위해 필요
                    'title',           // 리믹스 포스트 제목
                    'track_title',     // 원곡 제목
                    'artist_name',     // 원곡 가수 이름
                    'album_cover_url'
                ])
                ->map(function($remix) {
                    return [
                        'id' => $remix->id,
                        'title' => $remix->title,
                        'track_title' => $remix->track_title,
                        'artist_name' => $remix->artist_name,
                        'album_cover_url' => $remix->album_cover_url,
                        'user_name' => $remix->user ? $remix->user->name : 'Unknown', // 작성자 이름 추출
                    ];
                }),
        ]);
    }

    // 상세보기
    public function show(Post $post)
    {
        // 조회수 추가
        $post->increment('view_count');

        $post->loadCount(['likes', 'comments']);

        // 1. 게시글과 관련된 관계 로드
        $post->load([
            'user', 
            'remix.user',
            'comments' => function($query) {
                $query->whereNull('parent_id')
                    ->latest()
                    ->with(['user', 'replies.user']);
            }
        ]);

        // 2. 관심곡 여부 판별 로직 추가
        if (auth()->check() && $post->remix) {
            $isFavorite = auth()->user()->favoriteTracks()
                ->where('track_id', (string)$post->remix->id)
                ->where('type', 'remix')
                ->exists();
            
            // 데이터 객체에 실시간으로 속성 주입
            $post->remix->isFavorite = $isFavorite;
        } else if ($post->remix) {
            $post->remix->isFavorite = false;
        }

        // 게시글 랜더링
        return Inertia::render('Posts/Show', [
            'post' => $post
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'category' => 'required|string',
            'remix_id' => 'nullable|exists:remixes,id', // 리믹스 ID 검증 추가
        ]);

        // DB에 remix_id를 포함하여 저장
        $request->user()->posts()->create($validated);

        return redirect()->route('posts.index')->with('message', '게시글이 성공적으로 등록되었습니다.');
    }

    // 수정하기
    public function edit(Post $post)
    {
        // 본인글인지 체크
        if (auth()->id() !== $post->user_id)
        {
            abort(403, '수정 권한이 없습니다.');
        }

        return Inertia::render('Posts/Edit', [
            'post' => $post
        ]);
    }

    public function update(Request $request, Post $post)
    {
        // 본인 확인 
        if (auth()->id() !== $post->user_id)
        {
            abort(403, '수정 권한이 없습니다.');
        }

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'category' => 'required|string',
        ]);

        $post->update($validated);

        return redirect()->route('posts.show', $post->id)->with('message', '글이 수정되었습니다.');
    }

    public function destroy(Post $post)
    {
        // 1. 본인 확인 (작성자 본인만 삭제 가능하도록)
        if (auth()->id() !== $post->user_id) {
            abort(403, '삭제 권한이 없습니다.');
        }

        // 2. 게시글 삭제
        $post->delete();

        // 3. 목록 페이지로 리다이렉트
        return redirect()->route('posts.index')->with('message', '게시글이 삭제되었습니다.');
    }
}