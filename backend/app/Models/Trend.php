<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Trend extends Model
{
    //
    // 대량 할당(Mass Assignment) 허용
    protected $fillable = [
        'platform', 
        'category', 
        'rank', 
        'title', 
        'artist', 
        'album_cover_url', 
        'external_id'
    ];
}
