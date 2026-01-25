<?php

namespace App\Filament\Resources\RemixResource\Pages;

use App\Filament\Resources\RemixResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditRemix extends EditRecord
{
    protected static string $resource = RemixResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
