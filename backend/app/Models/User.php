<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Database\Eloquent\Relations\HasMany;

class User extends Authenticatable
{
    use HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'google_id',
        'kakao_id',
        'points',           
        'soundcloud_url',   
        'youtube_url',      
        'donation_info',    
        'bio',              
        'daw_info',         
        'public_email',
        'is_admin',
        'is_active',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function remixes(): HasMany 
    {
        return $this->hasMany(Remix::class);
    } 

    public function posts(): HasMany
    {
        return $this->hasMany(Post::class);
    }

    public function favoriteTracks() 
    {
        return $this->hasMany(FavoriteTrack::class);
    }

    public function canAccessPanel(\Filament\Panel $panel): bool
    {
        return $this->is_admin && $this->is_active;
    }
}