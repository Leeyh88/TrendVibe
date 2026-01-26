<?php

namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Contact extends Model
{
    use HasFactory;

    // 저장 가능한 필드 정의
    protected $fillable = ['email', 'message', 'is_read'];
}
