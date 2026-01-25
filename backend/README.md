# Trend Mixer
#### 바로가기
* [사이트 소개](#사이트-소개)
* [Laravel 핵심 기술](#laravel-핵심기술)
* [Vue.js 핵심기술](#vuejs-핵심기술)
* [데이터베이스 운영](#데이터베이스-운영)
* [도커 운영](#도커-운영)

- - -
## 사이트 소개
> **Laravel 11 & Vue.js (Inertia.js)** 기반의 현대적 아키텍처로 구축된 리믹스 투표 플랫폼입니다. 
> 단순한 기능을 넘어 **시스템 보안, 리소스 최적화, 데이터 자동화 파이프라인** 구축에 집중했습니다.

### 1. 서비스 내용
**TrendMixer**는 사용자가 직접 리믹스 음원을 발굴하고 평가하며 공유하는 참여형 플랫폼입니다. YouTube API를 통해 누구나 자신만의 리믹스 아카이브를 구축할 수 있으며, 이렇게 등록된 곡들은 1:1 믹스매치 시스템을 통해 사용자들의 실시간 투표로 경쟁하게 됩니다.

단순한 투표에 그치지 않고, 축적된 투표 로그를 정교하게 분석하여 실시간 인기 랭킹을 산출함으로써 공신력 있는 차트를 제공합니다. 또한, Node.js(Puppeteer) 기반의 크롤러를 통해 Spotify, SoundCloud 등 주요 플랫폼의 최신 핫트렌드 데이터를 자동으로 수집하여 사용자에게 통합된 음악 인사이트를 제시합니다. 모든 과정은 Inertia.js 기반의 SPA 환경에서 새로고침 없이 부드럽게 이루어지며, Tiptap 에디터가 통합된 커뮤니티를 통해 깊이 있는 음악적 소통을 지원합니다.

### 2. 적용기술
<img src="https://img.shields.io/badge/Laravel_11-FF2D20?style=for-the-badge&logo=laravel&logoColor=white"> <img src="https://img.shields.io/badge/Vue.js_3-4FC08D?style=for-the-badge&logo=vue.js&logoColor=white"> <img src="https://img.shields.io/badge/MariaDB-003545?style=for-the-badge&logo=mariadb&logoColor=white"> <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white"> <img src="https://img.shields.io/badge/Tailwind_CSS-06B6D4?style=for-the-badge&logo=tailwindcss&logoColor=white"> <img src="https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black">

1️⃣ **Mix Match**: 1:1 매칭 인터페이스를 통한 몰입감 있는 투표 경험 제공  
<img width="1370" height="1194" alt="스크린샷 2026-01-23 오후 11 25 33" src="https://github.com/user-attachments/assets/0a7c4960-b1ba-4b47-ab4a-f2ac8da75895" />

2️⃣ **Remix**: 전체 리믹스 등록 곡을 최신순/인기순으로 탐색할 수 있는 목록 페이지  
<img width="1125" height="1194" alt="스크린샷 2026-01-23 오후 11 27 01" src="https://github.com/user-attachments/assets/154f3015-71ba-4f8a-87e0-b371d7b070f8" />

3️⃣ **MyVibe**: 내가 등록한 리믹스의 득표 현황 및 좋아요한 핫트렌드곡, 리믹스곡 리스트 제공  
3️⃣ **MyVibe**: 내가 등록한 리믹스의 득표 현황 및 좋아요한 핫트렌드곡, 리믹스곡 리스트 제공  
<img width="1333" height="1197" alt="스크린샷 2026-01-24 오전 2 35 03" src="https://github.com/user-attachments/assets/80dd4b96-8d94-4732-b07c-5c54a5079592" />
<img width="1344" height="1207" alt="스크린샷 2026-01-24 오전 2 34 53" src="https://github.com/user-attachments/assets/3e62e7ff-fd9c-41d6-81c8-6cdb7220a6a7" />


4️⃣ **Community**: **Tiptap 에디터** 기반의 텍스트 환경을 통해 고품질의 음악 리뷰와 유저 간 소통을 지원하는 커뮤니티  
<img width="1355" height="1132" alt="스크린샷 2026-01-23 오후 11 28 36" src="https://github.com/user-attachments/assets/4cd67bcb-7336-4f44-a9a7-e20e835c39f1" />

5️⃣ **Ranking**: 축적된 투표 데이터를 기반으로 실시간 트렌드를 반영하여 산출된 **플랫폼 통합 인기 랭킹** 시스템
<img width="1288" height="1204" alt="스크린샷 2026-01-23 오후 11 29 14" src="https://github.com/user-attachments/assets/faec3b58-fc61-4f59-b662-23080452d01f" />

---

## Laravel 핵심기술

### 1. Inertia.js 기반 아키텍처
* **Zero-API 아키텍처**: `api.php`를 경유하는 추가적인 HTTP 요청 없이, 라라벨 컨트롤러에서 Vue 컴포넌트로 직접 데이터를 주입(`Inertia::render`)하여 데이터 로딩 속도를 최적화했습니다.
* **성능최적화**: 컨트롤러에서 필요한 데이터를 프롭스(Props) 형태로 직접 전달함으로써, 프론트엔드에서의 추가적인 데이터 요청(API Call) 없이도 빠른 초기 페이지 로딩을 구현했습니다.

```php
// web.php에서 Inertia 컴포넌트 랜더링 예제
Route::get('/rankings', function (Request $request) {
    // 정렬 기준 설정 (기존 로직 유지)
    $sort = $request->query('sort', 'votes');
    $column = ($sort === 'views') ? 'view_count' : 'vote_count';

    $userFavoriteIds = [];
    if (auth()->check()) {
        $userFavoriteIds = auth()->user()->favoriteTracks()
            ->pluck('track_id')
            ->toArray();
    }

    // 실시간 통계 데이터 계산 (추가된 부분)
    $stats = [
        // 전체 리믹스 곡의 누적 승리(점수) 합계
        'total_points' => number_format(Remix::sum('vote_count')),
        // 현재 DB에 등록된 총 리믹스 곡 수
        'total_remixes' => number_format(Remix::count()),
    ];

    // 3. 랭킹 데이터 조회
    $rankings = Remix::with(['user', 'genre', 'musicTrack'])
        ->orderBy($column, 'desc')
        ->take(20) // 10개는 조금 적을 수 있어 20개로 늘렸습니다.
        ->get()
        ->map(function ($remix) use ($userFavoriteIds) {
            $remix->isFavorite = in_array((string)$remix->id, $userFavoriteIds);
            return $remix;
        });

    return Inertia::render('Rankings/Index', [
        'rankings' => $rankings,
        'currentSort' => $sort,
        'stats' => $stats, // ✅ 프론트엔드로 통계 전달
        // 만약 장르 필터나 검색 기능이 필요하다면 아래도 함께 보냅니다.
        'genres' => Genre::all(), 
        'filters' => $request->only(['sort'])
    ]);
})->name('rankings');
```
### 2. Form Request를 활용한 로직 분리
* **유효성검사 분리**: `ProfileUpdateRequest`와 `LoginRequest` 등 커스텀 Request 클래스를 생성하여 컨트롤러에서 유효성 검사 로직을 완벽히 분리했습니다.
* **데이터 무결성 확보**: 프로필 업데이트 시 `Rule::unique`의 `ignore` 메서드를 활용하여 이메일 중복 체크를 정교하게 처리하고, 플랫폼별 전용 URL(SoundCloud, YouTube)에 대한 Validation을 적용했습니다.
```php
// 프로필변경 유효성검사 예시
class ProfileUpdateRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => [
                'required',
                'string',
                'lowercase',
                'email',
                'max:255',
                Rule::unique(User::class)->ignore($this->user()->id),
            ],
            'profile_photo' => ['nullable', 'image', 'mimes:jpg,jpeg,png', 'max:2048'],
            'public_email'   => ['nullable', 'email', 'max:255'],
            'soundcloud_url' => ['nullable', 'url', 'max:255', 'starts_with:https://soundcloud.com'], 
            'youtube_url'    => ['nullable', 'url', 'max:255'],
            'daw_info'       => ['nullable', 'string', 'max:100'],
            'bio'            => ['nullable', 'string', 'max:500'],
            'donation_info'  => ['nullable', 'string', 'max:1000'],
        ];
    }
}
```
### 3. 보안 및 로깅처리
* **Breeze기반 인증**: 
    - Laravel Breeze를 통해 표준 인증 시스템을 구축하였습니다.
* **이벤트 기반 보안 로깅**: 로그인 차단 발생 시 `Lockout` 이벤트를 발행하고, 이를 구독하여 보안 로그를 `storage/logs/laravel.log`에 실시간으로 기록합니다.
* **Brute-force 공격 방어**: `RateLimiter`를 활용하여 5회 이상 로그인 실패 시 즉시 접근을 차단하고, 유저에게 `availableIn()` 메서드로 계산된 재시도 대기 시간을 실시간으로 피드백합니다.
```php
 public function authenticate(): void
    {
        $this->ensureIsNotRateLimited();

        if (! Auth::attempt($this->only('email', 'password'), $this->boolean('remember'))) {
            RateLimiter::hit($this->throttleKey(), 300);

            throw ValidationException::withMessages([
                'email' => trans('auth.failed'),
            ]);
        }

        RateLimiter::clear($this->throttleKey());
    }

    //  로그인 요청이 5회이상 시도된 상태인지 확인 
    public function ensureIsNotRateLimited(): void
    {
        if (! RateLimiter::tooManyAttempts($this->throttleKey(), 5)) {
            return;
        }

        event(new Lockout($this));

        $seconds = RateLimiter::availableIn($this->throttleKey());

        throw ValidationException::withMessages([
            'email' => trans('auth.throttle', [
                'seconds' => $seconds,
                'minutes' => ceil($seconds / 60),
            ]),
        ]);
    }

    // 이메일과 IP 로 체크 
    public function throttleKey(): string
    {
        return Str::transliterate(Str::lower($this->string('email')).'|'.$this->ip());
    }
```
### 4. 소셜 로그인 (Google & Kakao)
* **표준 및 커스텀 드라이버 결합**: 
    - Laravel Socialite의 코어 SDK를 활용하여 **Google** 인증을 구현했습니다.
    - 공식 패키지에서 지원하지 않는 **Kakao** 인증을 위해 `SocialiteProviders`를 연동하고, `SocialiteWasCalled` 이벤트를 통해 커스텀 드라이버를 동적으로 주입(Dependency Injection)했습니다.
* **유저 데이터 정규화**: 플랫폼별로 상이한 유저 정보 포맷을 백엔드에서 일관된 규격으로 가공하여 시스템 DB에 통합 관리합니다.
### 5. Eloquent ORM & Relationships
* **데이터 모델링**: 모델 간의 관계를 정의하여 복잡한 Join문 없이도 객체지향형으로 처리하였습니다.  
* **쿼리 최적화**: 쿼리 조회 시 withCount()를 활용하여 댓글수, 좋아요 수를 구하는 쿼리를 최적화했습니다.
```php
// 
return Inertia::render('Posts/Index', [
    'posts' => Post::with('user')
        // 댓글 수와 좋아요 수를 쿼리에 포함
        ->withCount(['comments', 'likes']) 
        // 2. 카테고리가 있으면 해당 카테고리만 필터링
        ->when($category, function ($query, $category) {
            return $query->where('category', $category);
        })
        // 3. 검색어 필터
        ->when($search, function ($query, $search) {
            return $query->where(function($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                ->orWhere('content', 'like', "%{$search}%");
            });
        })
        ->latest()
        ->paginate(10)
        ->withQueryString(),
    'filters' => [
        'category' => $category,
        'search' => $search
    ],
    'boardStats' => $boardStats
]);
```

---

## Vue.js 핵심기술 (진행중)

### 1. 외부 API 전략적 활용 및 비용 최적화
* **YouTube IFrame API**: `Promise.all` 기반의 비동기 병렬 처리를 통해 두 개의 유튜브 플레이어를 동시에 제어하며 최적화된 믹스매치 환경을 구현했습니다. 
* **iTunes API 프론트엔드 처리**: API 할당량 제한이 없는 iTunes API의 특성을 파악하여 백엔드 프록시 없이 프론트엔드에서 직접 통신하도록 설계, 서버 리소스를 점유하지 않는 비용 효율적 아키텍처를 구현했습니다.

### 2. 성능 최적화
* **코드 스플리팅**: 사용자가 방문하는 시점에만 해당 페이지 리소스를 로드하는 **Dynamic Import**를 적용하여 초기 번들 크기를 줄이고 첫 화면 로딩 속도를 개선했습니다.

### 3. 컴포넌트 기반 아키텍처
* **재사용 가능한 UI**: 폼 입력, 리믹스 카드, 모달 등 핵심 UI를 컴포넌트화하여 개발 생산성을 높였습니다.  
* **상태 관리**: 회원 정보 및 실시간 투표 세션 데이터를 전역 상태로 관리하여 데이터 일관성을 유지합니다.

### 4. 커뮤니티
* **Tiptap Editor**: 커스터마이징 가능한 Tiptap(Vue 3 기반) 에디터를 도입하여, 사용자에게 워드 프로세서 수준의 풍부한 글쓰기 경험(Rich Text Editing)을 제공.
---

## 데이터베이스 운영

### 1. 관계형 데이터 모델링 (MariaDB)
* **테이블 정규화**: `Users`, `Remixes`, `MatchLogs` 테이블 간의 효율적인 관계 설정을 통해 데이터 무결성을 확보했습니다.
* **득표수 집계 최적화**: `MatchLog` 테이블에 투표 데이터를 기록하고, 이를 기반으로 리믹스의 실시간 승률 및 순위를 산출하는 로직을 구축했습니다.
* **상태 관리 설계**: `is_active` 컬럼을 활용하여 부적절한 게시물이나 비활성 사용자의 데이터를 실시간으로 필터링할 수 있도록 설계했습니다.


---

## 도커 운영

* **컨테이너화**: PHP-FPM, Nginx, MariaDB를 개별 컨테이너로 분리하여 독립적이고 일관된 운영 환경을 구축했습니다.
* **마운트**: 소스 코드와 DB 데이터를 볼륨으로 관리하여 컨테이너 재생성 시에도 데이터가 유지되도록 설계했습니다.


