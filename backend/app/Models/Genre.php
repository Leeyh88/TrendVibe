<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Genre extends Model
{
    //
    public function remixes(): HasMany 
    {
        return $this->hasMany(Remix::class);
    }
}
