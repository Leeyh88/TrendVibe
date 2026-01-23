<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UserResource\Pages;
use App\Filament\Resources\UserResource\RelationManagers;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;
use Filament\Forms\Components\Toggle;
use Filament\Tables\Columns\ToggleColumn;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;

class UserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static ?string $navigationIcon = 'heroicon-o-users';

    protected static ?string $navigationLabel = '사용자 관리';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                // 수정 폼에서 나란히 배치
                Forms\Components\Section::make('권한 및 상태 설정')
                    ->schema([
                        Toggle::make('is_admin')
                            ->label('관리자 권한')
                            ->helperText('체크 시 관리자 패널에 접속할 수 있습니다.'),
                        Toggle::make('is_active')
                            ->label('계정 활성 상태')
                            ->default(true)
                            ->helperText('체크 해제 시 서비스 이용이 제한됩니다.'),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
            // 1. 유저 ID (정렬 가능)
            Tables\Columns\TextColumn::make('id')
                ->label('ID')
                ->sortable(),

            // 2. 이름 (검색 및 정렬 가능)
            Tables\Columns\TextColumn::make('name')
                ->label('이름')
                ->searchable()
                ->sortable(),

            // 3. 이메일 (검색 가능)
            Tables\Columns\TextColumn::make('email')
                ->label('이메일')
                ->searchable(),

            TextColumn::make('remixes_count')
                ->label('리믹스')
                ->counts('remixes')
                ->badge() // 배지 스타일로 강조
                ->color('primary')
                ->sortable(),    

            TextColumn::make('posts_count')
                ->label('포스트')
                ->counts('posts')
                ->badge()
                ->color('success')
                ->sortable(),

            // 4. 관리자 여부 (아이콘으로 표시)
            Tables\Columns\IconColumn::make('is_admin')
                ->label('관리자')
                ->boolean(),

            // 5. 가입일 (포맷 지정 및 정렬)
            Tables\Columns\TextColumn::make('created_at')
                ->label('가입일')
                ->dateTime('Y-m-d H:i')
                ->sortable()
                ->toggleable(isToggledHiddenByDefault: true), // 평소엔 숨겨두고 선택 시 노출
                // 관리자 여부는 중요하므로 아이콘으로 명확히 표시
            IconColumn::make('is_admin')
                ->label('관리자')
                ->boolean()
                ->sortable(),

            // 활성 상태는 리스트에서 바로 껐다 켤 수 있게 ToggleColumn 사용
            ToggleColumn::make('is_active')
                ->label('활성 상태')
                ->onColor('success')
                ->offColor('danger'),
        ])
        ->filters([
            // 여기에 필터를 추가하면 목록 상단에서 필터링이 가능합니다.
            Tables\Filters\TernaryFilter::make('is_admin')
                ->label('관리자 여부'),
        ])
        ->actions([
            Tables\Actions\EditAction::make(), // 수정 버튼
            // Tables\Actions\DeleteAction::make(), // 삭제 버튼
        ])
        ->bulkActions([
            // Tables\Actions\DeleteBulkAction::make(), // 선택 삭제
        ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListUsers::route('/'),
            'create' => Pages\CreateUser::route('/create'),
            'edit' => Pages\EditUser::route('/{record}/edit'),
        ];
    }
}
