<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PointHistory extends Model
{
    protected $fillable = [
        'user_id', 
        'amount', 
        'reason', 
        'description', 
        'pointable_id', 
        'pointable_type'
    ];

    // 다형성 관계 설정 (게시글, 댓글 등 연결)
    public function pointable()
    {
        return $this->morphTo();
    }
}