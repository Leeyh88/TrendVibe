<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head, Link, router, usePage } from '@inertiajs/vue3';
import axios from 'axios';

// 메뉴 상태 관리 
const activeMenuId = ref(null);

const toggleUserMenu = (event, id) => {
    event.stopPropagation(); // 부모의 openVideo(remix) 실행 방지
    activeMenuId.value = activeMenuId.value === id ? null : id;
};

const closeMenu = () => {
    activeMenuId.value = null;
};

// 외부 클릭 시 메뉴 닫기
onMounted(() => window.addEventListener('click', closeMenu));
onUnmounted(() => window.removeEventListener('click', closeMenu));

// 컨트롤러에서 넘겨주는 데이터 정의
const props = defineProps({
    auth: Object,
    canLogin: Boolean,
    canRegister: Boolean,
    hotTrends: Array,
    latestFeedback: Array,
    leaderboard: Array
});

// --- 상태 관리 (State) ---
const isVideoModalOpen = ref(false);
const selectedSong = ref(null); // 모달용 선택된 곡 정보

// --- 계산된 속성 (Computed) ---
const totalLeaderboardVotes = computed(() => {
    return props.leaderboard.reduce((acc, item) => acc + (item.vote_count || 0), 0);
});

// --- 함수 (Methods) ---
const getCategoryName = (category) => {
    const names = { general: '자유', recommend: '추천', question: '질문' };
    return names[category] || category;
};

const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString();
};

const goToRemixList = (title, artist) => {
    router.get(route('remixes.index'), {
        track: `${title}|${artist}`,
        sort: 'popular'
    });
};

const getVoteWidth = (count) => {
    if (totalLeaderboardVotes.value === 0) return 0;
    return (count / totalLeaderboardVotes.value) * 100;
};

// 유튜브 모달 제어 (리더보드 클릭 시)
const openVideo = (remix) => {
    selectedSong.value = {
        id: remix.id,
        youtube_video_id: remix.youtube_video_id,
        title: remix.title,
        artist: remix.user?.name || 'Unknown Artist',
        platform: 'Remix',
        isFavorite: remix.isFavorite,
        type: 'remix'
    };
    isVideoModalOpen.value = true;
};

const closeVideo = () => {
    selectedSong.value = null;
    isVideoModalOpen.value = false;
};

// 관심곡 추가 확인 컨펌
const confirmFavorite = (trend) => {
    if (!props.auth.user) {
        if (confirm('로그인이 필요한 기능입니다. 로그인 페이지로 이동하시겠습니까?')) {
            router.get(route('login'));
        }
        return;
    }

    // 상태에 따른 메시지 동적 변경
    const message = trend.isFavorite 
        ? `[${trend.track_title}] 곡을 관심곡에서 제거하시겠습니까?` 
        : `[${trend.track_title}] 곡을 관심곡 목록에 추가하시겠습니까?`;

    if (confirm(message)) {
        addFavorite(trend);
    }
};

// 실제 서버 전송
const addFavorite = (trend) => {
    axios.post('/favorites/toggle', {
        track_id: trend.youtube_video_id,
        type: 'youtube',
        title: trend.track_title,
        thumbnail: trend.album_cover_url,
    })
    .then(res => {
        // 실시간 상태 업데이트 (반응성)
        trend.isFavorite = res.data.isFavorite;
        // alert는 사용자 흐름을 끊으므로 제거하거나 짧은 토스트로 대체하는 것이 좋습니다.
    })
    .catch(err => {
        if (err.response && err.response.status === 401) {
            alert('로그인이 필요한 기능입니다.');
        } else {
            console.error('오류 발생:', err);
        }
    });
};

// 모달 전용 관심곡 토글 함수
const toggleFavoriteFromModal = () => {
    if (!props.auth.user) {
        if (confirm('로그인이 필요한 기능입니다. 로그인 페이지로 이동하시겠습니까?')) {
            router.get(route('login'));
        }
        return;
    }

    const song = selectedSong.value;
    const isAdding = !song.isFavorite;

    if (confirm(isAdding ? '이 리믹스를 보관함에 담으시겠습니까?' : '보관함에서 제거하시겠습니까?')) {
        axios.post('/favorites/toggle', {
            track_id: String(song.id), // 리믹스는 ID값을 고유 키로 사용
            type: 'remix',            // 'youtube'와 구분하기 위해 'remix'로 전송
            title: song.title,
            thumbnail: song.thumbnail,
        })
        .then(res => {
            // 1. 모달 내 상태 업데이트
            song.isFavorite = res.data.isFavorite;
            
            // 2. 배경의 리더보드 리스트 상태도 동기화 (필요 시)
            const remixInList = props.leaderboard.find(r => r.id === song.id);
            if (remixInList) remixInList.isFavorite = res.data.isFavorite;
        });
    }
};
</script>

<template>
    <Head title="홈" />
    <AuthenticatedLayout>
        <div class="py-10 bg-[#FBFBFE] min-h-screen">
            <div class="max-w-6xl mx-auto px-6">
                
              <header class="mb-12 relative overflow-hidden bg-gradient-to-br from-indigo-700 via-indigo-800 to-black p-10 sm:p-16 rounded-[3rem] text-white shadow-2xl">
    <div class="relative z-10 max-w-2xl">
        <span v-if="!$page.props.auth.user" class="inline-block px-4 py-1.5 bg-white/10 backdrop-blur-md border border-white/20 rounded-full text-[10px] font-black uppercase tracking-[0.2em] mb-6">
            Start Your Remix Journey
        </span>
        <span v-else class="inline-block px-4 py-1.5 bg-indigo-500/30 backdrop-blur-md border border-indigo-400/30 rounded-full text-[10px] font-black uppercase tracking-[0.2em] mb-6">
            Welcome Back, {{ $page.props.auth.user.name }}!
        </span>

        <h1 class="text-4xl sm:text-6xl font-black tracking-tighter leading-[1.1] mb-6">
            당신의 음악적 감각을 <br/>
            <span class="text-indigo-400 italic">증명</span> 하세요
        </h1>

        <p class="text-white/60 text-sm sm:text-base font-bold leading-relaxed mb-10 max-w-lg">
            단순한 업로드를 넘어, <span class="text-white">AI 화성학 엔진</span>을 통해 <br class="hidden sm:block"/>
            당신의 MIDI 데이터를 정밀 분석하고 전문적인 피드백을 받아보세요.
        </p>

        <div class="flex flex-wrap gap-4">
            <template v-if="!$page.props.auth.user">
                <Link :href="route('register')" class="px-8 py-4 bg-white text-indigo-900 rounded-2xl font-black text-sm hover:bg-indigo-50 transition-all shadow-lg">시작하기</Link>
                <Link :href="route('login')" class="px-8 py-4 bg-white/10 backdrop-blur-md border border-white/20 text-white rounded-2xl font-black text-sm hover:bg-white/20 transition-all">로그인</Link>
            </template>
            <template v-else>
                <Link :href="route('midi.index')" class="px-8 py-4 bg-indigo-500 text-white rounded-2xl font-black text-sm hover:bg-indigo-400 transition-all shadow-xl shadow-indigo-900/20 flex items-center gap-2 border border-indigo-400/30">
                    <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                    </svg>
                    AI MIDI 피드백 받기
                </Link>

                <Link :href="route('remixes.create')" class="px-8 py-4 bg-white/10 backdrop-blur-md border border-white/20 text-white rounded-2xl font-black text-sm hover:bg-white/20 transition-all flex items-center gap-2">
                    <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3"><path d="M12 4v16m8-8H4" /></svg>
                    리믹스 업로드
                </Link>
            </template>
        </div>
    </div>

    <div class="absolute right-[-10%] top-[-10%] w-[50%] h-[120%] opacity-20 pointer-events-none rotate-12 bg-gradient-to-l from-indigo-500 to-transparent rounded-full blur-3xl"></div>
</header>

                <section class="mb-16">
                    <div class="flex items-center justify-between mb-8 px-2">
                        <div>
                            <h2 class="text-2xl font-black text-gray-900 tracking-tighter uppercase italic">Top Mixers</h2>
                            <p class="text-[10px] font-bold text-indigo-500 uppercase tracking-widest mt-1">현재 가장 뜨거운 리믹스 랭킹</p>
                        </div>
                        
                        <Link :href="route('rankings')" 
                            class="group relative flex items-center gap-3 px-6 py-3 bg-gray-900 text-white rounded-2xl font-black text-[11px] uppercase tracking-[0.2em] transition-all duration-300 hover:bg-indigo-600 hover:shadow-[0_0_25px_rgba(79,70,229,0.5)] hover:-translate-y-1 active:scale-95">
                            
                            <span class="relative z-10">View All Charts</span>
                            
                            <div class="relative z-10 w-6 h-6 bg-white/10 rounded-xl flex items-center justify-center group-hover:bg-white group-hover:text-indigo-600 transition-all duration-300">
                                <svg xmlns="http://www.w3.org/2000/svg" 
                                    class="w-3.5 h-3.5 transform group-hover:translate-x-0.5 transition-transform duration-300" 
                                    fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="4">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M13 7l5 5m0 0l-5 5m5-5H6" />
                                </svg>
                            </div>

                            <div class="absolute inset-0 bg-indigo-500 rounded-2xl opacity-0 group-hover:opacity-20 blur-xl transition-opacity"></div>
                        </Link>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                        <div v-for="(remix, index) in leaderboard.slice(0, 3)" :key="remix.id" 
                            @click="openVideo(remix)"
                            class="bg-white rounded-[2.5rem] p-8 border border-gray-100 shadow-sm hover:shadow-xl transition-all cursor-pointer group flex items-center gap-6">
                            
                            <div class="relative flex-shrink-0">
                                <span class="text-3xl font-black italic transition-colors w-8 inline-block text-center" 
                                    :class="index < 3 ? 'text-indigo-600' : 'text-gray-100 group-hover:text-gray-200'">
                                    {{ index + 1 }}
                                </span>
                            </div>

                            <div class="min-w-0 flex-grow">
                                <p class="text-base font-black text-gray-900 truncate leading-tight group-hover:text-indigo-600 transition-colors">
                                    {{ remix.title }}
                                </p>

                                <div class="flex items-center gap-2 mt-2.5 relative">
                                    <div class="relative">
                                        <button 
                                            @click.stop="toggleUserMenu($event, remix.id)"
                                            class="group/user flex items-center gap-1.5 px-2.5 py-1 bg-slate-50 hover:bg-indigo-50 rounded-lg transition-all border border-slate-100 hover:border-indigo-100"
                                        >
                                            <svg xmlns="http://www.w3.org/2000/svg" class="w-3 h-3 text-slate-400 group-hover/user:text-indigo-500 transition-colors" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                                <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"></path>
                                                <circle cx="12" cy="7" r="4"></circle>
                                            </svg>

                                            <span class="text-[10px] font-black text-slate-500 group-hover/user:text-indigo-600 uppercase tracking-tight">
                                                {{ remix.user?.name || 'Unknown' }}
                                            </span>

                                            <svg class="w-2.5 h-2.5 text-slate-300 group-hover/user:text-indigo-400 transition-colors" fill="currentColor" viewBox="0 0 20 20">
                                                <path d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" />
                                            </svg>
                                        </button>

                                        <div v-if="activeMenuId === remix.id" 
                                            class="absolute left-0 mt-2 w-44 bg-white border border-gray-100 rounded-2xl shadow-2xl z-[50] py-2 overflow-hidden animate-in fade-in zoom-in-95 duration-200"
                                            @click.stop>
                                            <Link :href="`/public-profile/${remix.user?.id}`" 
                                                class="flex items-center gap-3 px-4 py-2.5 text-[11px] font-black text-gray-700 hover:bg-indigo-50 hover:text-indigo-600 transition-all">
                                                <span class="text-sm"></span> 회원정보 보기
                                            </Link>
                                            <div class="h-[1px] bg-gray-50 mx-2 my-1"></div>
                                            <button class="flex items-center gap-3 w-full text-left px-4 py-2.5 text-[11px] font-black text-gray-300 cursor-not-allowed">
                                                <span class="text-sm"></span> 팔로우 (준비중)
                                            </button>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="flex items-center gap-2 mt-3">
                                    <div class="w-full bg-gray-100 h-1.5 rounded-full overflow-hidden">
                                        <div class="bg-indigo-500 h-full transition-all duration-1000" 
                                            :style="{ width: getVoteWidth(remix.vote_count) + '%' }"></div>
                                    </div>
                                    <span class="text-[9px] font-black text-indigo-600 uppercase italic tabular-nums">
                                        {{ remix.vote_count }} <span class="text-[8px] text-gray-300">pts</span>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>

                <div class="grid grid-cols-1 lg:grid-cols-3 gap-10">
                    
                    <div class="lg:col-span-2 space-y-12">
                        <section>
                            <div class="flex items-center justify-between mb-8 px-2">
                                <div>
                                    <h2 class="text-2xl font-black text-gray-900 tracking-tighter uppercase italic">Hot Trends</h2>
                                    <p class="text-[10px] font-bold text-indigo-500 uppercase tracking-widest mt-1">가장 핫한 리믹스 재료</p>
                                </div>
                            </div>

                            <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                                <div v-for="(trend, index) in hotTrends" :key="index" 
                                    @click="goToRemixList(trend.track_title, trend.artist_name)"
                                    class="group relative bg-white rounded-[2.5rem] p-5 border border-gray-100 shadow-sm hover:shadow-xl hover:-translate-y-1 transition-all cursor-pointer">
                                    
                                    <div class="aspect-video bg-gray-100 rounded-[1.8rem] overflow-hidden mb-5">
                                        <img :src="trend.album_cover_url" class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700" />
                                    </div>

                                    <div class="px-2 relative">
                                        <span class="px-2 py-0.5 bg-indigo-50 text-indigo-600 text-[9px] font-black rounded uppercase mb-2 inline-block">
                                            {{ trend.total }} Remixes
                                        </span>
                                        <h3 class="text-lg font-black text-gray-900 truncate tracking-tight pr-10">{{ trend.track_title }}</h3>
                                        <p class="text-xs text-gray-400 font-bold uppercase mt-1">{{ trend.artist_name }}</p>

                                       <button 
                                            @click.stop="confirmFavorite(trend)"
                                            class="absolute right-0 bottom-0 w-10 h-10 rounded-2xl flex items-center justify-center transition-all shadow-lg active:scale-95"
                                            :class="trend.isFavorite 
                                                ? 'bg-white text-black hover:bg-indigo-600 hover:text-white border border-gray-200' 
                                                : 'bg-gray-900 text-white hover:bg-indigo-600'"
                                        >
                                            <svg v-if="!trend.isFavorite" xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M12 4v16m8-8H4" />
                                            </svg>
                                            <svg v-else xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M20 12H4" />
                                            </svg>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </section>
                    </div>

                    <aside>
                        <div class="sticky top-10">
                            <div class="flex items-center justify-between mb-8 px-2">
                                <h2 class="text-2xl font-black text-gray-900 tracking-tighter uppercase italic">Latest Feed</h2>
                            </div>
                            <div class="bg-white rounded-[2.5rem] border border-gray-100 shadow-sm divide-y divide-gray-50 overflow-hidden">
                                <div v-for="post in latestFeedback" :key="post.id" 
                                    class="relative p-6 hover:bg-gray-50 transition-colors flex flex-col group">
                                    
                                    <Link :href="route('posts.show', post.id)" class="absolute inset-0 z-10"></Link>

                                    <div class="relative z-20 pointer-events-none"> <div class="flex items-center gap-3 mb-3">
                                            <span class="px-2 py-0.5 bg-gray-100 text-gray-500 text-[8px] font-black rounded uppercase tracking-widest">
                                                {{ getCategoryName(post.category) }}
                                            </span>
                                        </div>
                                        <div>
                                            <p class="text-sm font-black text-gray-800 group-hover:text-indigo-600 transition-colors line-clamp-2 leading-snug">
                                                {{ post.title }}
                                            </p>
                                        </div>
                                    </div>

                                    <div class="flex items-center justify-between mt-4 relative z-30">
                                        <div class="relative">
                                            <button 
                                                @click.prevent.stop="toggleUserMenu($event, 'post-' + post.id)"
                                                class="group/user flex items-center gap-1.5 px-2 py-0.5 bg-slate-50 hover:bg-indigo-50 rounded-lg transition-all border border-slate-100 hover:border-indigo-100"
                                            >
                                                <img v-if="post.user?.profile_photo_url" 
                                                    :src="post.user.profile_photo_url" 
                                                    class="w-3.5 h-3.5 rounded-full object-cover shadow-xs" />
                                                
                                                <svg v-else xmlns="http://www.w3.org/2000/svg" class="w-3 h-3 text-slate-400 group-hover/user:text-indigo-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                                    <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"></path>
                                                    <circle cx="12" cy="7" r="4"></circle>
                                                </svg>

                                                <span class="text-[9px] font-black text-slate-500 group-hover/user:text-indigo-600 uppercase">
                                                    {{ post.user?.name }}
                                                </span>
                                                
                                                <svg class="w-2 h-2 text-slate-300 group-hover/user:text-indigo-400" fill="currentColor" viewBox="0 0 20 20">
                                                    <path d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" />
                                                </svg>
                                            </button>

                                            <div v-if="activeMenuId === 'post-' + post.id" 
                                                class="absolute left-0 mt-2 w-40 bg-white border border-gray-100 rounded-xl shadow-2xl z-[100] py-1.5 overflow-hidden animate-in fade-in zoom-in-95 duration-200"
                                                @click.stop>
                                                <Link :href="`/public-profile/${post.user?.id}`" 
                                                    class="flex items-center gap-2.5 px-3 py-2 text-[10px] font-black text-gray-700 hover:bg-indigo-50 hover:text-indigo-600 transition-all">
                                                    <span>👤</span> 회원정보 보기
                                                </Link>
                                            </div>
                                        </div>
                                        
                                        <span class="text-[9px] text-gray-300 font-medium">{{ formatDate(post.created_at) }}</span>
                                    </div>
                                </div>

                                <Link :href="route('posts.index')" class="block w-full py-5 bg-gray-50 text-center text-[10px] font-black text-gray-400 uppercase tracking-widest hover:bg-indigo-600 hover:text-white transition-all">
                                    Show More Feed →
                                </Link>
                            </div>
                        </div>
                    </aside>

                </div>
            </div>
        </div>

        <div v-if="isVideoModalOpen" class="fixed inset-0 z-[100] flex items-center justify-center p-4">
            <div class="absolute inset-0 bg-black/90 backdrop-blur-md" @click="closeVideo"></div>
            
            <div class="relative w-full max-w-2xl bg-[#0A0A0B] rounded-[3rem] overflow-hidden shadow-2xl animate-in zoom-in duration-300 border border-white/10">
                <button @click="closeVideo" class="absolute top-6 right-8 z-10 text-white/50 hover:text-white transition-all">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" /></svg>
                </button>

                <div class="p-8 pt-12">
                    <div class="flex justify-center mb-6">
                        <span class="px-4 py-1.5 bg-indigo-600 text-white text-[10px] font-black rounded-full uppercase tracking-[0.2em] shadow-lg">
                            {{ selectedSong?.platform }} Trending
                        </span>
                    </div>

                    <div class="text-center space-y-6">
                        <div class="relative aspect-video mx-auto rounded-[1.5rem] overflow-hidden shadow-2xl border border-white/5 bg-black group">
                            <iframe v-if="selectedSong?.youtube_video_id"
                                :key="selectedSong.youtube_video_id"
                                :src="`https://www.youtube.com/embed/${selectedSong.youtube_video_id}?autoplay=1&modestbranding=1&rel=0`"
                                class="w-full h-full"
                                frameborder="0"
                                allow="autoplay; encrypted-media; picture-in-picture"
                                allowfullscreen>
                            </iframe>
                        </div>

                        <div class="pt-2">
                            <h3 class="text-2xl sm:text-3xl font-black text-white tracking-tighter leading-tight italic uppercase truncate px-4">
                                {{ selectedSong?.title }}
                            </h3>
                            <p class="text-indigo-400 font-bold text-sm uppercase tracking-widest mt-1">
                                {{ selectedSong?.artist }}
                            </p>
                        </div>
                    </div>

                    <div class="mt-10 grid grid-cols-1 gap-3">
                        <button 
                            @click="toggleFavoriteFromModal"
                            class="py-5 rounded-2xl font-black text-sm uppercase tracking-widest transition-all text-center flex items-center justify-center gap-2"
                            :class="selectedSong?.isFavorite 
                                ? 'bg-indigo-600 text-white shadow-lg shadow-indigo-500/20' 
                                : 'bg-white text-black hover:bg-gray-100'"
                        >
                            <svg v-if="!selectedSong?.isFavorite" xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
                            </svg>
                            <svg v-else xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
                            </svg>
                            {{ selectedSong?.isFavorite ? 'Saved in My Vibe' : 'Add to Favorites' }}
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </AuthenticatedLayout>
</template>

<style scoped>
.no-scrollbar::-webkit-scrollbar { display: none; }
.no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
</style>