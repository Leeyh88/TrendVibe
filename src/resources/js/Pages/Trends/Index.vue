<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head, Link, usePage, router } from '@inertiajs/vue3';
import { ref, watch, computed, onMounted } from 'vue';
import axios from 'axios';

const props = defineProps({
    charts: { type: Object, default: () => ({}) }
});

const modalPlayer = ref(null);
const selectedSong = ref(null);
const isModalOpen = ref(false);
const isVideoLoading = ref(true); // 영상 로딩 상태 추가

const loadYouTubeAPI = () => {
    if (!window.YT) {
        const tag = document.createElement('script');
        tag.src = "https://www.youtube.com/iframe_api";
        const firstScriptTag = document.getElementsByTagName('script')[0];
        firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
    }
};

// 유튜브 API 스크립트 로드
onMounted(() => {
    loadYouTubeAPI();
});

// 모달 플레이어 초기화 함수
const initModalPlayer = (videoId) => {
    // window.YT.Player가 준비될 때까지 100ms마다 재확인
    if (!window.YT || !window.YT.Player) {
        setTimeout(() => initModalPlayer(videoId), 100);
        return;
    }

    const elementId = 'modal-youtube-player';
    
    // 만약 영상 출력 영역이 사라졌다면 중단
    if (!document.getElementById(elementId)) return;

    // 기존 플레이어 청소
    if (modalPlayer.value && modalPlayer.value.destroy) {
        try { modalPlayer.value.destroy(); } catch (e) { console.error(e); }
    }

    modalPlayer.value = new window.YT.Player(elementId, {
        videoId: videoId,
        playerVars: { 
            'autoplay': 1, 
            'controls': 1, 
            'modestbranding': 1, 
            'rel': 0,
            'playsinline': 1 
        },
        events: {
            'onReady': (event) => {
                isVideoLoading.value = false;
                event.target.playVideo();
            },
            'onError': (e) => {
                console.error("YouTube Player Error:", e);
                isVideoLoading.value = false;
            }
        }
    });
};

// 모달 열기
const openSongModal = (song, platformName) => {
    selectedSong.value = { ...song, platform: platformName };
    isModalOpen.value = true;
    isVideoLoading.value = true;
    
    // v-if로 모달이 렌더링되고 DOM에 id="modal-youtube-player"가 나타난 후에 실행해야 함
    setTimeout(() => {
        initModalPlayer(song.youtube_video_id);
    }, 500); // 0.5초 대기로 안정성 확보
};

// 모달 닫기
const closeModal = () => {
    isModalOpen.value = false;
    if (modalPlayer.value && modalPlayer.value.stopVideo) {
        modalPlayer.value.stopVideo();
    }
    setTimeout(() => {
        selectedSong.value = null;
        if (modalPlayer.value && modalPlayer.value.destroy) {
            modalPlayer.value.destroy();
            modalPlayer.value = null;
        }
    }, 300);
};

// --- 기존 탭/차트 로직 ---
const currentTab = ref('all');
const currentSubMenu = ref('미국 음악 Top 10');

const platforms = [
    { name: 'All Trends', value: 'all', color: 'bg-gray-900', icon: 'M', brandColor: '#6366f1' },
    { name: 'YouTube', value: 'youtube', color: 'bg-[#FF0000]', brandColor: '#FF0000', icon: 'Y' },
    { name: 'Spotify', value: 'spotify', color: 'bg-[#1DB954]', brandColor: '#1DB954', icon: 'S' },
    { name: 'SoundCloud', value: 'soundcloud', color: 'bg-[#FF5500]', brandColor: '#FF5500', icon: 'C' }
];

const subMenus = {
    all: [{ name: '미국 음악 Top 10', value: 'youtube_us_songs' }],
    youtube: [
        { name: '국내 음악 Top 10', value: 'youtube_kr_songs' },
        { name: '국내 영상 Top 10', value: 'youtube_kr_trend' },
        { name: '미국 음악 Top 10', value: 'youtube_us_songs' },
        { name: '미국 영상 Top 10', value: 'youtube_us_trend' }
    ],
    spotify: [{ name: 'Top 50 - Global', value: 'spotify' }],
    soundcloud: [{ name: 'New & Hot', value: 'soundcloud' }]
};

watch(currentTab, (newTab) => {
    currentSubMenu.value = newTab === 'youtube' ? 'youtube_kr_songs' : subMenus[newTab][0].value;
});

const getSafeCharts = computed(() => {
    const safeData = { ...props.charts };
    let youtubeKey = currentTab.value === 'youtube' ? currentSubMenu.value : 'youtube_us_songs';
    
    // 유튜브 키 매칭
    if (safeData[youtubeKey]) {
        safeData['youtube'] = safeData[youtubeKey];
    }

    platforms.forEach(p => {
        if (p.value !== 'all') {
            const platformData = safeData[p.value] || [];
            
            if (platformData.length === 0) {
                // 데이터가 없을 때 더미 생성
                safeData[p.value] = Array.from({ length: 5 }, (_, i) => ({
                    rank: i + 1,
                    title: `${p.name} 트렌드 곡 #${i + 1}`,
                    artist: "Artist Name",
                    youtube_video_id: 'mlbheOTF9AQ', 
                    album_cover_url: null
                }));
            } else {
                // 데이터가 있을 때 ID 강제 확인
                safeData[p.value] = platformData.map(song => ({
                    ...song,
                    youtube_video_id: song.external_id || 'mlbheOTF9AQ' 
                }));
            }
        }
    }); // platforms.forEach 닫기

    return safeData;
}); // computed 닫기

const setTab = (tab) => { currentTab.value = tab; };

const toggleFavoriteFromModal = () => {
    const page = usePage();
    if (!page.props.auth.user) {
        if (confirm('로그인이 필요한 기능입니다. 로그인 페이지로 이동하시겠습니까?')) {
            router.get(route('login'));
        }
        return;
    }

    const song = selectedSong.value;
    
    axios.post('/favorites/toggle', {
        track_id: song.youtube_video_id,
        type: 'youtube', // 핫트렌드는 유튜브 기반 데이터임
        title: song.title,
        thumbnail: song.album_cover_url,
    })
    .then(res => {
        // 실시간 상태 업데이트
        song.isFavorite = res.data.isFavorite;
        
        // 메인 리스트 데이터도 동기화 (필요 시)
        // 이 페이지는 computed로 데이터를 생성하므로 song 객체만 수정해도 반영됩니다.
    })
    .catch(err => console.error(err));
};
</script>

<template>
    <Head title="핫트렌드" />
    <AuthenticatedLayout>
        <div class="py-12 bg-[#F8FAFC] min-h-screen font-sans">
            <div class="max-w-6xl mx-auto px-6">
                <header class="mb-10 flex flex-col md:flex-row md:items-end justify-between gap-6">
                    <div>
                        <div class="flex items-center gap-2 mb-2">
                            <span class="px-2 py-0.5 bg-indigo-600 text-white text-[10px] font-black rounded uppercase tracking-wider">Trend Hunter</span>
                        </div>
                        <h1 class="text-4xl font-black text-gray-900 tracking-tighter uppercase italic">Hot Trends</h1>
                        <p class="text-gray-400 font-bold mt-1 uppercase tracking-widest text-[10px]">Discover your next remix material across platforms.</p>
                    </div>
                </header>

                <div class="grid grid-cols-1 lg:grid-cols-3 gap-8 text-indigo-900">
                    <div class="lg:col-span-2 space-y-6">
                        <div class="bg-white rounded-[2.5rem] shadow-sm border border-gray-100 overflow-hidden">
                            <div class="p-2 flex items-center gap-1 overflow-x-auto no-scrollbar border-b border-gray-50">
                                <button v-for="platform in platforms" :key="platform.value" @click="setTab(platform.value)"
                                    class="px-5 py-2.5 rounded-2xl text-[10px] sm:text-xs font-black transition-all whitespace-nowrap uppercase tracking-tighter"
                                    :class="[currentTab === platform.value ? `${platform.color} text-white shadow-lg` : 'text-gray-400 hover:bg-gray-50']">
                                    {{ platform.name }}
                                </button>
                            </div>
                            <div class="px-6 py-4 flex items-center gap-3 overflow-x-auto no-scrollbar">
                                <button v-for="sub in subMenus[currentTab]" :key="sub.value" @click="currentSubMenu = sub.value"
                                    class="text-[11px] font-black uppercase tracking-widest transition-all"
                                    :class="currentSubMenu === sub.value ? 'text-indigo-600' : 'text-gray-300 hover:text-gray-500'">
                                    # {{ sub.name }}
                                </button>
                            </div>
                        </div>

                        <div class="grid grid-cols-1 gap-6">
                            <template v-for="platform in platforms.filter(p => p.value !== 'all')" :key="platform.value">
                                <div v-if="currentTab === 'all' || currentTab === platform.value" 
                                     class="bg-white rounded-[2.5rem] p-8 shadow-sm border border-gray-100 group transition-all hover:shadow-xl hover:shadow-indigo-50/50">
                                    
                                    <div class="flex items-center justify-between mb-8">
                                        <div class="flex items-center gap-4">
                                            <div :class="platform.color" class="w-12 h-12 rounded-2xl flex items-center justify-center text-white shadow-xl font-black italic text-xl">
                                                {{ platform.icon }}
                                            </div>
                                            <div>
                                                <h2 class="text-2xl font-black text-gray-900 tracking-tight leading-none italic uppercase">{{ platform.name }}</h2>
                                                <span class="text-[10px] font-black uppercase tracking-widest mt-1 block italic opacity-70" :style="{ color: platform.brandColor }">
                                                    {{ currentSubMenu }}
                                                </span>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="divide-y divide-gray-50">
                                        <div v-for="song in getSafeCharts[platform.value]" :key="song.rank"
                                            @click="openSongModal(song, platform.name)" 
                                            class="flex items-center gap-6 py-4 hover:bg-indigo-50/20 transition-all rounded-2xl px-4 -mx-4 group/item cursor-pointer">
                                            
                                            <span class="text-2xl font-black italic text-gray-100 group-hover/item:text-indigo-600 transition-colors w-8">
                                                {{ String(song.rank).padStart(2, '0') }}
                                            </span>

                                            <div class="w-12 h-12 rounded-lg bg-gray-50 flex-shrink-0 flex items-center justify-center text-gray-200 overflow-hidden">
                                                <img v-if="song.album_cover_url" :src="song.album_cover_url" class="w-full h-full object-cover" />
                                                <svg v-else class="w-6 h-6" fill="currentColor" viewBox="0 0 24 24"><path d="M12 3v10.55c-.59-.34-1.27-.55-2-.55-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4V7h4V3h-6z"/></svg>
                                            </div>

                                            <div class="flex-grow min-w-0">
                                                <h4 class="font-black text-gray-900 leading-tight truncate group-hover/item:text-indigo-600 transition-colors">
                                                    {{ song.title }}
                                                </h4>
                                                <p class="text-[11px] text-gray-400 font-bold uppercase mt-0.5">
                                                    {{ song.artist }}
                                                </p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </template>
                        </div>
                    </div>

                    <aside class="space-y-8">
                        <div class="bg-gray-900 rounded-[2.5rem] p-8 text-white shadow-xl shadow-indigo-100 relative overflow-hidden group">
                            <div class="relative z-10">
                                <h3 class="font-black text-xs uppercase tracking-[0.2em] text-indigo-400 mb-6 italic">Mixer's Lab</h3>
                                <p class="text-sm font-black leading-snug mb-6 uppercase">Found your material?<br/>Add it to battle now.</p>
                                <Link :href="route('remixes.index')" class="inline-flex items-center text-[10px] font-black uppercase tracking-widest border-b-2 border-indigo-500 pb-1 hover:text-indigo-400 transition-colors">
                                    Go to Remixes →
                                </Link>
                            </div>
                        </div>
                    </aside>
                </div>
            </div>
        </div>
    </AuthenticatedLayout>

    <Transition name="modal">
        <div v-if="isModalOpen" class="fixed inset-0 z-[100] flex items-center justify-center p-4 sm:p-6">
            <div class="absolute inset-0 bg-gray-900/90 backdrop-blur-sm" @click="closeModal"></div>
            
            <div class="relative bg-[#1A1D23] w-full max-w-lg rounded-[2.5rem] overflow-hidden shadow-2xl border border-white/10">
                <button @click="closeModal" class="absolute top-6 right-6 text-white/40 hover:text-white z-20">
                    <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
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

                            <div v-else class="absolute inset-0 flex flex-col items-center justify-center bg-gray-800 text-center p-6">
                                <svg class="w-12 h-12 text-white/10 mb-4" fill="currentColor" viewBox="0 0 24 24"><path d="M12 3v10.55c-.59-.34-1.27-.55-2-.55-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4V7h4V3h-6z"/></svg>
                                <p class="text-white/40 text-[10px] font-black uppercase tracking-widest mb-4">No Video Preview Found</p>
                                
                                <a :href="`https://www.youtube.com/results?search_query=${selectedSong?.artist} ${selectedSong?.title}`" 
                                target="_blank"
                                class="px-4 py-2 bg-white/5 border border-white/10 rounded-xl text-[9px] font-black text-white uppercase hover:bg-white/10 transition-all">
                                Search on YouTube →
                                </a>
                            </div>
                        </div>

                        <div class="pt-2">
                            <h3 class="text-2xl sm:text-3xl font-black text-white tracking-tighter leading-tight italic uppercase truncate">
                                {{ selectedSong?.title }}
                            </h3>
                            <p class="text-indigo-400 font-bold text-sm uppercase tracking-widest mt-1">
                                {{ selectedSong?.artist }}
                            </p>
                        </div>
                    </div>

                    
                        <div class="mt-10 grid grid-cols-1 gap-3 px-2">
                            <button 
                                @click="toggleFavoriteFromModal"
                                class="py-5 rounded-2xl font-black text-sm uppercase tracking-widest transition-all text-center flex items-center justify-center gap-2"
                                :class="selectedSong?.isFavorite 
                                    ? 'bg-indigo-600 text-white shadow-lg shadow-indigo-500/20' 
                                    : 'bg-white/10 text-white hover:bg-white/20 border border-white/10'"
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
    </Transition>
</template>

<style scoped>
.no-scrollbar::-webkit-scrollbar { display: none; }
.no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }

.modal-enter-active, .modal-leave-active {
    transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}
.modal-enter-from, .modal-leave-to {
    opacity: 0;
    transform: scale(0.9) translateY(20px);
}
</style>