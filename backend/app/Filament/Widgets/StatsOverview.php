<?php
namespace App\Filament\Widgets;

use App\Models\MatchLog;
use App\Models\User;
use App\Models\Remix;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends BaseWidget
{
    protected function getStats(): array
    {
        return [
            Stat::make('총 회원 수', User::count())
                ->description('전체 가입자')
                ->descriptionIcon('heroicon-m-users')
                ->color('success'),

            Stat::make('전체 리믹스', Remix::count())
                ->description('업로드된 게시물')
                ->descriptionIcon('heroicon-m-musical-note')
                ->chart([7, 2, 10, 3, 15, 4, 17])
                ->color('warning'),
            Stat::make('전체 매칭수', MatchLog::count())
                ->description('활발한 믹스매치 진행 중')
                ->descriptionIcon('heroicon-m-arrows-right-left') // 교차 화살표 아이콘으로 변경
                ->chart([15, 4, 10, 2, 12, 20, 25])
                ->color('info'),
        ];
    }
}