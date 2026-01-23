<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Remix extends Model
{
    // 데이터 삽입 허용 컬럼
    protected $fillable = [
        'user_id',
        'music_track_id', 
        'genre_id', 
        'title', 
        'youtube_url', 
        'youtube_video_id', 
        'description',
        'view_count',
        'vote_count',
        'track_title',       
        'artist_name',      
        'album_cover_url',   
        'itunes_track_id',   
    ];

    /**
     * 장르와의 관계 (N:1)
     * 리믹스는 하나의 장르에 속합니다.
     */
    public function genre(): BelongsTo
    {
        return $this->belongsTo(Genre::class);
    }

    /**
     * 원곡과의 관계 (N:1)
     * 리믹스는 하나의 원곡에 속합니다.
     */
    public function musicTrack(): BelongsTo
    {
        return $this->belongsTo(MusicTrack::class);
    }

    public function user(): BelongsTo {
        // Remix 테이블의 user_id를 기준으로 User테이블과 연결
        return $this->belongsTo(User::class);
    }

    public function matchLogs() {
        return $this->hasMany(MatchLog::class);
    }

    public function winLogs() {
        return $this->hasMany(MatchLog::class, 'winner_id');
    }

    public function favoritedBy()
    {
        return $this->hasMany(FavoriteTrack::class, 'track_id')
                    ->where('type', 'remix');
    }
}