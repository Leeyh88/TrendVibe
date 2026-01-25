<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FavoriteTrack extends Model
{
    use HasFactory;

    // DB에 한꺼번에 저장할 수 있는 컬럼들을 허용합니다 (보안 설정)
    protected $fillable = [
        'user_id',
        'track_id',
        'type',
        'title',
        'thumbnail',
    ];

    /**
     * 이 곡을 소유한 유저와의 관계 정의
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}