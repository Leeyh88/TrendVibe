<?php

namespace App\Filament\Resources\RemixResource\Pages;

use App\Filament\Resources\RemixResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListRemixes extends ListRecords
{
    protected static string $resource = RemixResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
