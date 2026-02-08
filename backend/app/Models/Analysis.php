<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Analysis extends Model
{
    use HasFactory;

    // 1. 대량 할당이 가능한 컬럼들 정의
    protected $fillable = [
        'user_id',
        'status',
        'file_path',
        'harmony_scores',
        'timeline_labels',
        'ai_comment',
        'bpm',
        'tracks',
        'duration',
    ];

    // 2. JSON 컬럼을 PHP 배열로 자동 변환 (매우 중요!)
    protected $casts = [
        'harmony_scores' => 'array',
        'timeline_labels' => 'array',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];
}