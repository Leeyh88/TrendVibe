<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Comment extends Model
{
    protected $fillable = ['content','user_id','post_id','parent_id'];

    public function user() { return $this->belongsTo(User::class); }
    public function post() { return $this->belongsTo(Post::class); }

    public function replies()
    {
        // 하나의 댓글은 여러 개의 대댓글을 가질 수 있음
        return $this->hasMany(Comment::class, 'parent_id');
    }

    public function parent()
    {
        // 대댓글은 하나의 부모 댓글에 속함
        return $this->belongsTo(Comment::class, 'parent_id');
    }
}
