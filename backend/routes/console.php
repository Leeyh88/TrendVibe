<?php
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schedule;
use Illuminate\Support\Facades\Process;

// 1. 유튜브 데이터 수집 (방금 만드신 커맨드)
// 매일 새벽 2시에 실행
Schedule::command('trends:fetch')->dailyAt('02:00');

// 2. 노드 크롤러 실행 (Spotify 등)
// 유튜브 수집 30분 뒤에 실행하거나, 원하는 시간에 배치
Schedule::call(function () {
    // 도커 환경에서 crawler 컨테이너의 index.js를 실행하는 방식입니다.
    // 'trend-crawler'는 docker-compose.yml에 정의한 서비스 이름이어야 합니다.
    $result = Process::run('docker exec trend-crawler node index.js');
    
    if ($result->successful()) {
        Log::info('Node 크롤러 작업 성공');
    } else {
        Log::error('Node 크롤러 작업 실패: ' . $result->errorOutput());
    }
})->dailyAt('02:30');