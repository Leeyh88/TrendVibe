<?php
namespace App\Filament\Resources;

use App\Filament\Resources\RemixResource\Pages;
use App\Models\Remix;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Tables\Columns\TextColumn;

class RemixResource extends Resource
{
    protected static ?string $model = Remix::class;
    protected static ?string $navigationIcon = 'heroicon-o-musical-note';
    protected static ?string $navigationLabel = '리믹스 관리';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('곡 정보')
                    ->schema([
                        Forms\Components\TextInput::make('title')
                            ->label('리믹스 제목')
                            ->required()
                            ->columnSpanFull(),
                        Forms\Components\TextInput::make('artist_name')
                            ->label('아티스트명')
                            ->required(),
                        Forms\Components\TextInput::make('track_title')
                            ->label('원곡 제목')
                            ->required(),
                        Forms\Components\Select::make('genre_id')
                            ->label('장르')
                            ->relationship('genre', 'name') // Genre 모델과의 관계
                            ->searchable()
                            ->preload()
                            ->required(),
                        Forms\Components\TextInput::make('youtube_video_id')
                            ->label('YouTube 비디오 ID')
                            ->required()
                            ->helperText('유튜브 주소의 v= 뒤에 있는 11자리 코드입니다.'),
                    ])->columns(2),

                Forms\Components\Section::make('설정 및 상태')
                    ->schema([
                        Forms\Components\Select::make('user_id')
                            ->label('작성자')
                            ->relationship('user', 'name')
                            ->searchable()
                            ->required(),
                        Forms\Components\Toggle::make('is_active')
                            ->label('노출 여부')
                            ->default(true),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')->sortable(),
                // 유튜브 썸네일 미리보기 추가
                Tables\Columns\ImageColumn::make('youtube_video_id')
                    ->label('썸네일')
                    ->getStateUsing(fn ($record) => "https://img.youtube.com/vi/{$record->youtube_video_id}/mqdefault.jpg"),
                
                Tables\Columns\TextColumn::make('title')
                    ->label('제목')
                    ->searchable()
                    ->limit(30),
                    
                Tables\Columns\TextColumn::make('user.name')
                    ->label('작성자')
                    ->sortable(),

                Tables\Columns\TextColumn::make('genre.name')
                    ->label('장르')
                    ->badge(),

                Tables\Columns\TextColumn::make('vote_count')
                    ->label('투표수')
                    ->sortable()
                    ->alignCenter(),

                // winLogs 관계의 개수를 '승리 횟수(득표수)'로 표시
                TextColumn::make('win_logs_count')
                    ->label('실제 득표수(승리)')
                    ->counts('winLogs') // 모델의 winLogs() 관계 개수를 가져옴
                    ->sortable()
                    ->alignCenter()
                    ->badge()
                    ->color('success'),

                Tables\Columns\ToggleColumn::make('is_active')
                    ->label('활성상태'),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('등록일')
                    ->dateTime('Y-m-d')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('genre')
                    ->relationship('genre', 'name')
                    ->label('장르별 보기'),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListRemixes::route('/'),
            'create' => Pages\CreateRemix::route('/create'),
            'edit' => Pages\EditRemix::route('/{record}/edit'),
        ];
    }
}