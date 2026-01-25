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
const isVideoLoading = ref(true);

const loadYouTubeAPI = () => {
    if (!window.YT) {
        const tag = document.createElement('script');
        tag.src = "https://www.youtube.com/iframe_api";
        const firstScriptTag = document.getElementsByTagName('script')[0];
        firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
    }
};

onMounted(() => {
    loadYouTubeAPI();
});

const initModalPlayer = (videoId) => {
    if (!window.YT || !window.YT.Player) {
        setTimeout(() => initModalPlayer(videoId), 100);
        return;
    }

    const elementId = 'modal-youtube-player';
    if (!document.getElementById(elementId)) return;

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
            'onError': () => { isVideoLoading.value = false; }
        }
    });
};

const openSongModal = (song, platformName) => {
    // 스포티파이의 경우 external_id가 유튜브 ID가 아닐 수 있으므로 구분
    selectedSong.value = { 
        ...song, 
        platform: platformName,
        // 유튜브 플랫폼일 때만 바로 재생, 아닐 경우 검색 유도
        youtube_video_id: platformName === 'YouTube' ? song.external_id : null 
    };
    isModalOpen.value = true;
    isVideoLoading.value = true;
    
    if (selectedSong.value.youtube_video_id) {
        setTimeout(() => initModalPlayer(selectedSong.value.youtube_video_id), 500);
    } else {
        isVideoLoading.value = false;
    }
};

const closeModal = () => {
    isModalOpen.value = false;
    if (modalPlayer.value && modalPlayer.value.stopVideo) modalPlayer.value.stopVideo();
    setTimeout(() => {
        selectedSong.value = null;
        if (modalPlayer.value && modalPlayer.value.destroy) {
            modalPlayer.value.destroy();
            modalPlayer.value = null;
        }
    }, 300);
};

// --- 탭 및 메뉴 로직 ---
const currentTab = ref('all');
const currentSubMenu = ref('youtube_kr_songs');

const platforms = [
    { name: 'All Trends', value: 'all', color: 'bg-gray-900', icon: 'M', brandColor: '#6366f1' },
    { name: 'YouTube', value: 'youtube', color: 'bg-[#FF0000]', brandColor: '#FF0000', icon: 'Y' },
    { name: 'Spotify', value: 'spotify', color: 'bg-[#1DB954]', brandColor: '#1DB954', icon: 'S' },
    { name: 'SoundCloud', value: 'soundcloud', color: 'bg-[#FF5500]', brandColor: '#FF5500', icon: 'C' }
];

const subMenus = {
    all: [{ name: '전체 보기', value: '' }],
    youtube: [
        { name: '국내 음악 Top 10', value: 'youtube_kr_songs' },
        { name: '국내 영상 Top 10', value: 'youtube_kr_trend' },
        { name: '미국 음악 Top 10', value: 'youtube_us_songs' },
        { name: '미국 영상 Top 10', value: 'youtube_us_trend' }
    ],
    spotify: [
        { name: '국내 Top 10', value: 'Korea' }, 
        { name: '글로벌 Top 10', value: 'Global' }
    ],
    soundcloud: [{ name: 'New & Hot', value: 'soundcloud' }]
};

// 탭 변경 시 서브 메뉴 초기값 설정
watch(currentTab, (newTab) => {
    if (newTab === 'all') currentSubMenu.value = '';
    else if (newTab === 'youtube') currentSubMenu.value = 'youtube_kr_songs';
    else if (newTab === 'spotify') currentSubMenu.value = 'Korea';
    else currentSubMenu.value = subMenus[newTab][0].value;
});

const getSafeCharts = computed(() => {
    const safeData = { ...props.charts };
    
    // 1. 현재 활성화된 리스트 추출 (Active Tab 전용)
    let activeKey = currentSubMenu.value;
    if (currentTab.value === 'spotify') activeKey = `spotify_${currentSubMenu.value}`;
    
    safeData['active_list'] = safeData[activeKey] || [];

    // 2. 플랫폼별 기본 데이터 전처리 (All 탭용)
    platforms.forEach(p => {
        if (p.value !== 'all') {
            let defaultKey = p.value;
            if (p.value === 'youtube') defaultKey = 'youtube_kr_songs';
            if (p.value === 'spotify') defaultKey = 'spotify_Global';

            const rawData = safeData[defaultKey] || safeData[p.value] || [];
            safeData[p.value] = rawData.length > 0 ? rawData : [{ rank: 1, title: '데이터 준비 중', artist: '' }];
        }
    });

    return safeData;
});

const setTab = (tab) => { currentTab.value = tab; };

const toggleFavoriteFromModal = () => {
    const page = usePage();
    if (!page.props.auth.user) {
        if (confirm('로그인이 필요한 기능입니다.')) router.get(route('login'));
        return;
    }

    const song = selectedSong.value;
    axios.post('/favorites/toggle', {
        track_id: song.external_id,
        type: song.platform.toLowerCase(),
        title: song.title,
        thumbnail: song.album_cover_url,
    })
    .then(res => { song.isFavorite = res.data.isFavorite; })
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
                    </div>
                </header>

                <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    <div class="lg:col-span-2 space-y-6">
                        <div class="bg-white rounded-[2.5rem] shadow-sm border border-gray-100 overflow-hidden">
                            <div class="p-2 flex items-center gap-1 overflow-x-auto no-scrollbar border-b border-gray-50">
                                <button v-for="platform in platforms" :key="platform.value" @click="setTab(platform.value)"
                                    class="px-5 py-2.5 rounded-2xl text-[10px] sm:text-xs font-black transition-all uppercase"
                                    :class="[currentTab === platform.value ? `${platform.color} text-white shadow-lg` : 'text-gray-400 hover:bg-gray-50']">
                                    {{ platform.name }}
                                </button>
                            </div>
                            <div v-if="currentTab !== 'all'" class="px-6 py-4 flex items-center gap-3 overflow-x-auto no-scrollbar">
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
                                                    {{ currentTab === 'all' ? 'Top 10' : subMenus[currentTab].find(s => s.value === currentSubMenu)?.name }}
                                                </span>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="divide-y divide-gray-50">
                                        <div v-for="song in (currentTab === platform.value ? getSafeCharts.active_list : getSafeCharts[platform.value])" 
                                            :key="song.id"
                                            @click="openSongModal(song, platform.name)" 
                                            class="flex items-center gap-6 py-4 hover:bg-indigo-50/20 transition-all rounded-2xl px-4 -mx-4 group/item cursor-pointer">
                                            
                                            <span class="text-2xl font-black italic text-gray-100 group-hover/item:text-indigo-600 transition-colors w-8 text-center">
                                                {{ song.rank }}
                                            </span>

                                            <div class="w-12 h-12 rounded-lg bg-gray-100 flex-shrink-0 overflow-hidden shadow-inner">
                                                <img v-if="song.album_cover_url" :src="song.album_cover_url" class="w-full h-full object-cover" />
                                                <div v-else class="w-full h-full flex items-center justify-center text-gray-300">
                                                    <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 24 24"><path d="M12 3v10.55c-.59-.34-1.27-.55-2-.55-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4V7h4V3h-6z"/></svg>
                                                </div>
                                            </div>

                                            <div class="flex-grow min-w-0">
                                                <h4 class="font-black text-gray-900 leading-tight truncate group-hover/item:text-indigo-600 transition-colors uppercase italic">
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
                        <div class="bg-gray-900 rounded-[2.5rem] p-8 text-white shadow-xl relative overflow-hidden">
                            <h3 class="font-black text-xs uppercase tracking-[0.2em] text-indigo-400 mb-6 italic">Mixer's Lab</h3>
                            <p class="text-sm font-black leading-snug mb-6 uppercase">Found your material?<br/>Add it to battle now.</p>
                            <Link :href="route('remixes.index')" class="inline-flex items-center text-[10px] font-black uppercase tracking-widest border-b-2 border-indigo-500 pb-1 hover:text-indigo-400 transition-colors">
                                Go to Remixes →
                            </Link>
                        </div>
                    </aside>
                </div>
            </div>
        </div>
    </AuthenticatedLayout>

    <Transition name="modal">
        <div v-if="isModalOpen" class="fixed inset-0 z-[100] flex items-center justify-center p-4">
            <div class="absolute inset-0 bg-gray-900/95 backdrop-blur-md" @click="closeModal"></div>
            <div class="relative bg-[#1A1D23] w-full max-w-lg rounded-[2.5rem] overflow-hidden shadow-2xl border border-white/10">
                <button @click="closeModal" class="absolute top-6 right-6 text-white/40 hover:text-white z-20">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
                </button>

                <div class="p-8 pt-12 text-center">
                    <span class="px-4 py-1.5 bg-indigo-600 text-white text-[10px] font-black rounded-full uppercase tracking-widest mb-6 inline-block">
                        {{ selectedSong?.platform }} Trending
                    </span>

                    <div class="aspect-video bg-black rounded-[1.5rem] overflow-hidden mb-6 shadow-2xl border border-white/5 relative">
                        <iframe v-if="selectedSong?.platform === 'YouTube'"
                            :src="`https://www.youtube.com/embed/${selectedSong.external_id}?autoplay=1`"
                            class="w-full h-full" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen>
                        </iframe>
                        <div v-else class="w-full h-full flex flex-col items-center justify-center p-6 bg-gradient-to-br from-gray-800 to-gray-900">
                            <p class="text-white font-black uppercase tracking-tighter mb-4 italic">No Direct Video Preview</p>
                            <a :href="`https://www.youtube.com/results?search_query=${selectedSong?.artist} ${selectedSong?.title}`" 
                               target="_blank" class="px-6 py-3 bg-white/10 rounded-2xl text-[10px] font-black text-white uppercase hover:bg-white/20 border border-white/10 transition-all">
                               Search on YouTube →
                            </a>
                        </div>
                    </div>

                    <h3 class="text-2xl font-black text-white italic uppercase truncate">{{ selectedSong?.title }}</h3>
                    <p class="text-indigo-400 font-bold text-sm uppercase tracking-widest mt-1">{{ selectedSong?.artist }}</p>

                    <button @click="toggleFavoriteFromModal"
                        class="mt-8 w-full py-5 rounded-2xl font-black text-sm uppercase tracking-widest transition-all"
                        :class="selectedSong?.isFavorite ? 'bg-indigo-600 text-white shadow-lg' : 'bg-white/5 text-white border border-white/10 hover:bg-white/10'">
                        {{ selectedSong?.isFavorite ? 'Saved in My Vibe' : 'Add to Favorites' }}
                    </button>
                </div>
            </div>
        </div>
    </Transition>
</template>

<style scoped>
.no-scrollbar::-webkit-scrollbar { display: none; }
.modal-enter-active, .modal-leave-active { transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1); }
.modal-enter-from, .modal-leave-to { opacity: 0; transform: scale(0.9) translateY(20px); }
</style>