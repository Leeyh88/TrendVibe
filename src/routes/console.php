<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

// 매시간 분마다 Command 실행(테스트용 - php artisan schedule:work)
Schedule::command('trends:fetch')->everyMinute();

// 매일 00시에 실행(서버에서 실행시 예정 - 크론탭으로 처리)
// Schedule::command('trends:fetch')->dailyAt('00:00');

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');
