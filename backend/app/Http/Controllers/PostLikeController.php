<?php

namespace App\Http\Controllers;
use App\Models\Post;
use Illuminate\Http\Request;

class PostLikeController extends Controller
{
/**
     * 좋아요 토글 처리
     */
    public function store(Post $post) // ✅ 반드시 public function으로 감싸야 합니다.
    {
        // 현재 로그인한 유저가 이 게시글에 누른 좋아요가 있는지 확인
        $like = $post->likes()->where('user_id', auth()->id())->first();

        if ($like) {
            // 이미 좋아요를 눌렀다면 삭제 (취소)
            $like->delete();
        } else {
            // 좋아요가 없다면 새로 생성
            $post->likes()->create([
                'user_id' => auth()->id()
            ]);
        }

        return back(); // 이전 페이지로 리다이렉트
    }
}
