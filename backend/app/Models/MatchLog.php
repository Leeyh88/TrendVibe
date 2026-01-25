<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MatchLog extends Model
{
    protected $fillable = ['user_id', 'winner_id', 'loser_id'];

    public function winner()
    {
        return $this->belongsTo(Remix::class, 'winner_id');
    }

    public function loser()
    {
        return $this->belongsTo(Remix::class, 'loser_id');
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
