<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head, Link, router, usePage } from '@inertiajs/vue3';
import { ref, computed, onMounted, onUnmounted } from 'vue';
import axios from 'axios'; 

const props = defineProps({
    rankings: Array,
    currentSort: String,
    stats: Object,
    auth: Object 
});

// 1. 메뉴 상태를 저장할 변수
const activeMenuId = ref(null);

// 2. 메뉴를 껐다 켰다 하는 함수
const toggleUserMenu = (event, id) => {
    // 부모 요소의 클릭 이벤트(예: 비디오 재생)가 실행되지 않도록 방지
    event.stopPropagation(); 
    
    // 이미 열려있는 메뉴를 다시 누르면 닫고, 아니면 해당 ID의 메뉴를 켬
    activeMenuId.value = activeMenuId.value === id ? null : id;
    
    console.log("메뉴 토글됨:", id, "현재 상태:", activeMenuId.value); // 디버깅용
};

// 3. 메뉴 바깥 영역을 클릭하면 메뉴가 닫히도록 설정
const closeMenu = () => {
    activeMenuId.value = null;
};

onMounted(() => {
    window.addEventListener('click', closeMenu);
});

onUnmounted(() => {
    window.removeEventListener('click', closeMenu);
});

// --- 상태 관리 (State) ---
const selectedSong = ref(null); // 모달에 표시될 데이터 객체
const isModalOpen = ref(false);

const changeSort = (sortType) => {
    router.get(route('rankings'), { sort: sortType }, {
        preserveState: true, 
        replace: true
    });
};

// 유튜브 ID 추출 유틸리티
const getYoutubeId = (url) => {
    if (!url) return '';
    const regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
    const match = url.match(regExp);
    return (match && match[2].length === 11) ? match[2] : '';
}

// 모달 열기 함수 (데이터 정제)
const openVideo = (data) => {
    const videoId = getYoutubeId(data.youtube_url);
    
    selectedSong.value = {
        id: data.id,
        youtube_video_id: videoId,
        title: data.title,
        artist: data.user?.name || data.music_track?.artist || 'Unknown Artist',
        thumbnail: `https://img.youtube.com/vi/${videoId}/mqdefault.jpg`,
        platform: 'Remix Chart',
        isFavorite: data.isFavorite, // ✅ 컨트롤러에서 넘겨준 초기값
        type: 'remix' // 랭킹 곡은 리믹스 타입
    };
    isModalOpen.value = true;
};

const closeModal = () => {
    isModalOpen.value = false;
    selectedSong.value = null;
}

// ✅ 관심곡 토글 기능 (axios)
const toggleFavoriteFromModal = () => {
    const page = usePage();
    if (!page.props.auth.user) {
        if (confirm('로그인이 필요한 기능입니다. 로그인 페이지로 이동하시겠습니까?')) {
            router.get(route('login'));
        }
        return;
    }

    const song = selectedSong.value;
    const isAdding = !song.isFavorite;

    // 컨펌 메시지 동적 처리
    const message = isAdding 
        ? `[${song.title}] 곡을 보관함에 추가하시겠습니까?` 
        : `[${song.title}] 곡을 보관함에서 제거하시겠습니까?`;

    if (confirm(message)) {
        axios.post('/favorites/toggle', {
            track_id: String(song.id),
            type: 'remix',
            title: song.title,
            thumbnail: song.thumbnail,
        })
        .then(res => {
            // 1. 모달 내 상태 즉시 업데이트
            song.isFavorite = res.data.isFavorite;
            
            // 2. 배경 리스트(rankings)의 해당 항목 상태도 실시간 동기화
            const target = props.rankings.find(r => r.id === song.id);
            if (target) {
                target.isFavorite = res.data.isFavorite;
            }
        })
        .catch(err => {
            console.error('관심곡 처리 중 오류:', err);
            alert('오류가 발생했습니다. 다시 시도해 주세요.');
        });
    }
};
</script>

<template>
    <Head title="순위" />
    <AuthenticatedLayout>
        <div class="py-12 bg-[#F8FAFC] min-h-screen">
            <div class="max-w-6xl mx-auto px-6">
                
                <header class="mb-10 flex flex-col md:flex-row md:items-end justify-between gap-6">
                    <div>
                        <div class="flex items-center gap-2 mb-2">
                            <span class="px-2 py-0.5 bg-indigo-600 text-white text-[10px] font-black rounded uppercase">Live Updates</span>
                        </div>
                        <h1 class="text-4xl font-black text-gray-900 tracking-tighter uppercase italic">Live Vibe Chart</h1>
                        <p class="text-gray-400 font-bold mt-1 uppercase tracking-widest text-[10px]">The Survivors of Mix Match Duel.</p>
                    </div>
                </header>

                <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    <div class="lg:col-span-2 space-y-6">
                        <div class="bg-white rounded-[2.5rem] shadow-sm border border-gray-100 overflow-hidden">
                            <div class="divide-y divide-gray-50">
                                <div v-for="(remix, index) in rankings" :key="remix.id" 
                                    @click="openVideo(remix)"
                                    class="p-6 hover:bg-indigo-50/20 transition-all group cursor-pointer">
                                    <div class="flex items-center gap-6">
                                        <div class="w-10 flex-shrink-0 text-center">
                                            <span v-if="index === 0" class="text-3xl">🥇</span>
                                            <span v-else-if="index === 1" class="text-3xl">🥈</span>
                                            <span v-else-if="index === 2" class="text-3xl">🥉</span>
                                            <span v-else class="font-black text-sm text-gray-200 group-hover:text-indigo-300 transition-colors italic">#{{ index + 1 }}</span>
                                        </div>

                                        <div class="w-16 h-16 bg-gray-100 rounded-2xl overflow-hidden flex-shrink-0 shadow-sm border border-gray-50">
                                            <img :src="`https://img.youtube.com/vi/${getYoutubeId(remix.youtube_url)}/mqdefault.jpg`" 
                                                 class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" />
                                        </div>

                                        <div class="flex-grow min-w-0">
                                            <div class="flex items-center gap-2 mb-1">
                                                <span class="text-[10px] font-black text-indigo-500 uppercase tracking-widest">{{ remix.genre?.name }}</span>
                                                <span class="w-1 h-1 bg-gray-200 rounded-full"></span>
                                                <span class="text-[10px] font-bold text-gray-400 uppercase tracking-tighter">{{ remix.artist_name }} - {{ remix.track_title }}</span>
                                            </div>
                                            <h4 class="text-lg font-black text-gray-900 group-hover:text-indigo-600 transition-colors leading-snug truncate">
                                                {{ remix.title }}
                                                <span v-if="remix.isFavorite" class="ml-1 text-indigo-500 text-xs">♥</span>
                                            </h4>

                                            <div class="flex items-center gap-2 mt-2 relative">
                                                <div class="relative">
                                                    <button 
                                                        @click.stop="toggleUserMenu($event, 'ranking-' + remix.id)"
                                                        class="group/user flex items-center gap-1.5 px-2 py-0.5 bg-slate-50 hover:bg-indigo-50 rounded-lg transition-all border border-slate-100 hover:border-indigo-100"
                                                    >
                                                        <img v-if="remix.user?.profile_photo_url" 
                                                            :src="remix.user.profile_photo_url" 
                                                            class="w-3.5 h-3.5 rounded-full object-cover" />
                                                        
                                                        <svg v-else xmlns="http://www.w3.org/2000/svg" class="w-3 h-3 text-slate-400 group-hover/user:text-indigo-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                                            <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"></path>
                                                            <circle cx="12" cy="7" r="4"></circle>
                                                        </svg>

                                                        <span class="text-[9px] font-black text-slate-500 group-hover/user:text-indigo-600 uppercase tracking-tight">
                                                            {{ remix.user?.name || 'Unknown' }}
                                                        </span>

                                                        <svg class="w-2 h-2 text-slate-300 group-hover/user:text-indigo-400" fill="currentColor" viewBox="0 0 20 20">
                                                            <path d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" />
                                                        </svg>
                                                    </button>

                                                    <div v-if="activeMenuId === 'ranking-' + remix.id" 
                                                        class="absolute left-0 mt-2 w-40 bg-white border border-gray-100 rounded-xl shadow-2xl z-[100] py-1.5 overflow-hidden animate-in fade-in zoom-in-95 duration-200"
                                                        @click.stop>
                                                        <Link :href="`/public-profile/${remix.user?.id}`" 
                                                            class="flex items-center gap-2.5 px-3 py-2 text-[10px] font-black text-gray-700 hover:bg-indigo-50 hover:text-indigo-600 transition-all">
                                                            <span>👤</span> 회원정보 보기
                                                        </Link>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="flex flex-col items-end gap-1 flex-shrink-0">
                                            <span class="text-xl font-black text-gray-900 tabular-nums italic">
                                                {{ (currentSort === 'views' ? remix.view_count : remix.vote_count).toLocaleString() }}
                                            </span>
                                            <span class="text-[9px] font-black text-gray-300 uppercase tracking-widest">
                                                {{ currentSort === 'views' ? 'Views' : 'Wins' }}
                                            </span>
                                        </div>
                                    </div>
                                </div>
                                <div v-if="rankings.length === 0" class="py-24 text-center">
                                    <p class="text-gray-300 font-black uppercase tracking-widest">No Rankings Available</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <aside class="space-y-8">
                        <div class="bg-gray-900 rounded-[2.5rem] p-8 text-white shadow-xl shadow-indigo-100 relative overflow-hidden">
                            <div class="relative z-10">
                                <h3 class="font-black text-xs uppercase tracking-[0.2em] text-indigo-400 mb-6">Ranking Stats</h3>
                                <div class="grid grid-cols-2 gap-4">
                                    <div>
                                        <p class="text-[9px] font-bold text-white/40 uppercase mb-1">Total Votes</p>
                                        <p class="text-2xl font-black italic">{{ stats.total_points }}</p>
                                    </div>
                                    <div>
                                        <p class="text-[9px] font-bold text-white/40 uppercase mb-1">Total Mixes</p>
                                        <p class="text-2xl font-black italic">{{ stats.total_remixes }}</p>
                                    </div>
                                </div>
                            </div>
                            <div class="absolute -right-10 -bottom-10 w-32 h-32 bg-indigo-600 rounded-full blur-[60px] opacity-20"></div>
                        </div>

                        <div class="bg-white rounded-[2.5rem] p-8 border border-gray-100 shadow-sm">
                            <h3 class="font-black text-gray-900 text-[10px] uppercase tracking-widest mb-6 border-b pb-4 italic">Chart Guidelines</h3>
                            <ul class="space-y-5 text-[11px] font-bold text-gray-500 uppercase leading-relaxed">
                                <li class="flex gap-3 items-start"><span class="text-indigo-600">●</span> 순위는 믹스매치 배틀 승리 점수로 결정됩니다.</li>
                                <li class="flex gap-3 items-start"><span class="text-indigo-600">●</span> 모든 대결은 시스템 랜덤 매칭으로 진행됩니다.</li>
                            </ul>
                        </div>
                    </aside>
                </div>
            </div>
        </div>

        <div v-if="isModalOpen" class="fixed inset-0 z-[100] flex items-center justify-center p-4">
            <div class="absolute inset-0 bg-black/90 backdrop-blur-md" @click="closeModal"></div>
            
            <div class="relative w-full max-w-2xl bg-[#0A0A0B] rounded-[3rem] overflow-hidden shadow-2xl animate-in zoom-in duration-300 border border-white/10">
                <button @click="closeModal" class="absolute top-6 right-8 z-10 text-white/50 hover:text-white transition-all">
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
                            <div v-else class="absolute inset-0 flex flex-col items-center justify-center bg-gray-900 text-center p-6">
                                <p class="text-white/40 text-[10px] font-black uppercase tracking-widest">No Video Preview Found</p>
                            </div>
                        </div>

                        <div class="pt-2 px-4">
                            <h3 class="text-2xl sm:text-3xl font-black text-white tracking-tighter leading-tight italic uppercase truncate">
                                {{ selectedSong?.title }}
                            </h3>
                            <p class="text-indigo-400 font-bold text-sm uppercase tracking-widest mt-1">
                                {{ selectedSong?.artist }}
                            </p>
                        </div>
                    </div>

                    <div class="mt-10 px-4 mb-4">
                        <button 
                            @click="toggleFavoriteFromModal"
                            class="w-full py-5 rounded-2xl font-black text-sm uppercase tracking-widest transition-all text-center flex items-center justify-center gap-2 shadow-xl"
                            :class="selectedSong?.isFavorite 
                                ? 'bg-indigo-600 text-white shadow-indigo-500/20' 
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