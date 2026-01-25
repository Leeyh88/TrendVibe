<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Like extends Model
{
    protected $fillable = [
        'user_id',
        'post_id',
    ];

    // Post 모델과의 관계 
    public function post()
    {
        return $this->belongsTo(Post::class);
    }

    // User 모델과의 관계
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}