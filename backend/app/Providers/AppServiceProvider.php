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
	// 1. URL 생성을 도메인과 https로 완전히 박아버립니다.
        // \URL::forceRootUrl(config('app.url')); 
        // \URL::forceScheme('https');

        // 2. 만약 IP가 계속 나오면 서버 변수도 강제로 덮어씁니다.
        // if (app()->environment('production') || true) {
        //     $_SERVER['SERVER_NAME'] = 'trendvibe.kr';
        //     $_SERVER['HTTP_HOST'] = 'trendvibe.kr';
        // }
        // Vite::prefetch(concurrency: 3);

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
