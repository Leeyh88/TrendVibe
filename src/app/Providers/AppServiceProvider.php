<?php

namespace App\Providers;

use Illuminate\Support\Facades\Vite;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Event;
use SocialiteProviders\Manager\SocialiteWasCalled;
use SocialiteProviders\Kakao\KakaoExtendSocialite;
use Illuminate\Support\Facades\Log; 
use Illuminate\Auth\Events\Lockout; 

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Vite::prefetch(concurrency: 3);

        Event::listen(
            SocialiteWasCalled::class,
            [KakaoExtendSocialite::class, 'handle']
        );

        Event::listen(Lockout::class, function (Lockout $event) {
            Log::warning('Security Alert: User Lockout Detected', [
                'ip' => $event->request->ip(),
                'email' => $event->request->email,
                'user_agent' => $event->request->userAgent(),
                'timestamp' => now()->toDateTimeString(),
            ]);
        });
    }
}
