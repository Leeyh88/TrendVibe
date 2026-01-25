<?php

namespace App\Http\Controllers;

use App\Models\Post;
use App\Models\Comment;
use Illuminate\Http\Request;

class CommentController extends Controller
{
    // 댓글등록
    public function store(Request $request, Post $post)
    {
        $request->validate([
            'content' => 'required|string|max:1000',
            'parent_id' => 'nullable|exists:comments,id',
        ]);

        $post->comments()->create([
            'content' => $request->content,
            'user_id' => $request->user()->id,
            'parent_id' => $request->parent_id,
        ]);

        return back()->with('message', '댓글이 등록되었습니다.');
    }

    // 댓글 삭제
    public function destroy(Comment $comment) 
    {
        // 본인 확인
        if (auth()->id() !== $comment->user_id) {
            abort(403, '댓글 삭제 권한이 없습니다.');
        }

        // 삭제 실행
        $comment->delete();

        // 현재 상세페이지로 돌아가기
        return back()->with('message', '댓글이 삭제되었습니다.');
    }
}
