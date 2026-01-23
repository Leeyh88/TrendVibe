<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head, router, usePage } from '@inertiajs/vue3';
import { onMounted, onUnmounted, nextTick, ref, computed, onBeforeUnmount } from 'vue';
import axios from 'axios';

// 1. 메뉴 상태를 저장할 변수
const activeMenuId = ref(null);

// 2. 메뉴를 껐다 켰다 하는 함수
const toggleUserMenu = (event, id) => {
    event.preventDefault(); // 추가
    event.stopPropagation(); 
    
    // 단순화해서 테스트
    if (activeMenuId.value === id) {
        activeMenuId.value = null;
    } else {
        activeMenuId.value = id;
    }
};

// 3. 메뉴 바깥 영역을 클릭하면 메뉴가 닫히도록 설정
const closeMenu = () => {
    activeMenuId.value = null;
};

const goToProfile = (userId) => {
    // 1. 메뉴 닫기
    activeMenuId.value = null;
    
    // 2. 페이지 강제 이동
    router.visit(`/public-profile/${userId}`);
};

onMounted(() => {
    window.addEventListener('click', closeMenu);
});

onUnmounted(() => {
    window.removeEventListener('click', closeMenu);
});

const props = defineProps({
    candidates: { type: Array, default: () => [] }
});

const page = usePage();
const displayCandidates = computed(() => props.candidates || page.props.candidates || []);

const players = ref([null, null]);
const isMuted = ref([true, true]);
const confirmingId = ref(null);

const initYouTubePlayers = () => {
    if (!displayCandidates.value || displayCandidates.value.length < 2) return;
    displayCandidates.value.forEach((remix, index) => {
        const elementId = `player-${index}`;
        if (document.getElementById(elementId)) {
            if (players.value[index]) {
                try { players.value[index].destroy(); } catch (e) {}
            }
            players.value[index] = new window.YT.Player(elementId, {
                videoId: remix.youtube_video_id,
                playerVars: { 'autoplay': 1, 'mute': 1, 'controls': 0, 'start': 60, 'modestbranding': 1, 'playsinline': 1 },
                events: { 'onReady': (event) => event.target.playVideo() }
            });
        }
    });
};

onMounted(async () => {
    await nextTick();
    if (!window.YT) {
        const tag = document.createElement('script');
        tag.src = "https://www.youtube.com/iframe_api";
        const firstScriptTag = document.getElementsByTagName('script')[0];
        firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
        window.onYouTubeIframeAPIReady = initYouTubePlayers;
    } else { initYouTubePlayers(); }
});

onBeforeUnmount(() => {
    players.value.forEach(player => { if (player && player.destroy) player.destroy(); });
});

const selectWinner = (remixId) => {
    if (confirmingId.value !== null) return;

    const loser = displayCandidates.value.find(r => r.id !== remixId);
    const loserId = loser ? loser.id : null;

    router.post(route('worldcup.vote', { id: remixId }), {
        loser_id: loserId // 보낼 데이터 객체에 추가
    }, {
        preserveState: false,
        onStart: () => { confirmingId.value = remixId; },
        onError: () => { confirmingId.value = null; alert('오류가 발생했습니다.'); },
        onFinish: () => { confirmingId.value = null; }
    });
};

// ✅ 스킵 기능 수정: route('mixmatch')로 변경
const skipMatch = () => { 
    router.get(route('mixmatch'), {}, { 
        preserveScroll: false,
        replace: true // 히스토리에 남지 않게 교체
    }); 
};

const toggleSound = (index) => {
    if (!players.value[index]) return;
    if (isMuted.value[index]) {
        players.value.forEach((p, i) => { if (p && p.mute) { p.mute(); isMuted.value[i] = true; } });
        players.value[index].unMute();
        players.value[index].setVolume(50);
        isMuted.value[index] = false;
    } else {
        players.value[index].mute();
        isMuted.value[index] = true;
    }
};

const toggleFavorite = (remix) => {
    if (!page.props.auth.user) {
        if (confirm('로그인이 필요한 기능입니다. 로그인 페이지로 이동하시겠습니까?')) {
            router.get(route('login'));
        }
        return;
    }

    axios.post('/favorites/toggle', {
        track_id: String(remix.id),
        type: 'remix',
        title: remix.track_title || remix.title,
        thumbnail: `https://img.youtube.com/vi/${remix.youtube_video_id}/mqdefault.jpg`,
    })
    .then(res => {
        // 실시간 상태 반영
        remix.isFavorite = res.data.isFavorite;
    })
    .catch(err => {
        console.error('관심곡 처리 중 오류:', err);
    });
};
</script>

<template>
    <Head title="믹스매치" />

    <AuthenticatedLayout>
        <div class="py-12 bg-[#0F1115] min-h-screen"> 
            <div class="max-w-6xl mx-auto px-6 w-full">
                
                <header class="mb-10 flex items-center justify-between px-2">
                    <div class="flex items-center gap-4">
                        <div class="w-1 h-10 bg-indigo-600 rounded-full"></div>
                        <div>
                            <h1 class="text-3xl font-black text-white tracking-tighter uppercase italic leading-none">Mix Match</h1>
                            <p class="text-gray-500 font-bold uppercase tracking-[0.2em] text-[10px] mt-1">Who is the trend?</p>
                        </div>
                    </div>

                    <button @click="skipMatch" class="group flex items-center gap-2 text-gray-500 hover:text-white transition-all">
                        <span class="text-[10px] font-black uppercase tracking-widest">Skip Match</span>
                        <div class="w-8 h-8 rounded-full border border-gray-800 flex items-center justify-center group-hover:bg-indigo-600 group-hover:border-indigo-600 transition-all">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M13 5l7 7-7 7" /></svg>
                        </div>
                    </button>
                </header>

                <div class="relative">
                    <div class="absolute inset-0 flex items-center justify-center z-50 pointer-events-none">
                        <div class="relative flex items-center justify-center vs-float">
                            <div class="absolute w-24 h-24 bg-indigo-600/30 blur-[40px] rounded-full animate-pulse"></div>
                            <div class="w-16 h-16 sm:w-20 sm:h-20 bg-white text-black rounded-full flex items-center justify-center font-black text-xl sm:text-2xl italic shadow-[0_0_30px_rgba(255,255,255,0.2)] border-4 border-[#0F1115]">
                                VS
                            </div>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4 sm:gap-6">
                        <div v-for="(remix, index) in displayCandidates" :key="remix.id" 
     class="relative group overflow-hidden rounded-[2.5rem] bg-[#1A1D23] border border-gray-800 hover:border-indigo-500/50 transition-all duration-500 shadow-2xl">
    
    <div class="relative aspect-video bg-black overflow-hidden">
        <div :id="`player-${index}`" class="w-full h-full pointer-events-none scale-[1.02]"></div>
        <div class="absolute inset-0 bg-gradient-to-t from-[#1A1D23] via-transparent to-black/20"></div>

        <button @click.stop="toggleFavorite(remix)" 
                class="absolute bottom-20 right-6 w-12 h-12 rounded-full backdrop-blur-md flex items-center justify-center transition-all z-20 shadow-xl border"
                :class="remix.isFavorite ? 'bg-indigo-600 text-white border-indigo-400' : 'bg-white/10 text-white/40 border-white/10 hover:bg-white/20'">
            <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" :fill="remix.isFavorite ? 'currentColor' : 'none'" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M21 8.25c0-2.485-2.099-4.5-4.688-4.5-1.935 0-3.597 1.126-4.312 2.733-.715-1.607-2.377-2.733-4.313-2.733C5.1 3.75 3 5.765 3 8.25c0 7.22 9 12 9 12s9-4.78 9-12z" />
            </svg>
        </button>

        <button @click.stop="toggleSound(index)" 
                class="absolute bottom-6 right-6 w-12 h-12 rounded-full backdrop-blur-md flex items-center justify-center transition-all z-20 shadow-xl"
                :class="isMuted[index] ? 'bg-white/10 text-white/40 border border-white/10' : 'bg-indigo-600 text-white border border-indigo-400'">
            <svg v-if="isMuted[index]" xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3">
                <path stroke-linecap="round" stroke-linejoin="round" d="M17.25 9.75L19.5 12m0 0l2.25 2.25M19.5 12l2.25-2.25M19.5 12l-2.25 2.25m-10.5-6l4.72-4.72a.75.75 0 011.28.53v15.88a.75.75 0 01-1.28.53l-4.72-4.72H4.5a.75.75 0 01-.75-.75V9.75a.75.75 0 01.75-.75h2.25z" />
            </svg>
            <svg v-else xmlns="http://www.w3.org/2000/svg" class="w-5 h-5 animate-pulse" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3">
                <path stroke-linecap="round" stroke-linejoin="round" d="M19.114 5.636a9 9 0 010 12.728M16.463 8.288a5.25 5.25 0 010 7.424M6.75 8.25l4.72-4.72a.75.75 0 011.28.53v15.88a.75.75 0 01-1.28.53l-4.72-4.72H4.5a.75.75 0 01-.75-.75V8.25a.75.75 0 01.75-.75h2.25z" />
            </svg>
        </button>
    </div>

    <div class="p-8 sm:p-10 text-center relative">
        <div class="mb-8 px-4">
            <span class="text-[9px] font-black text-indigo-500 uppercase tracking-[0.3em] mb-2 block font-sans">Candidate 0{{ index + 1 }}</span>

            <div class="flex justify-center mb-4 relative">
                <div v-if="remix.user" class="relative">
                    <button 
                        @click.stop="toggleUserMenu($event, 'match-' + remix.id)"
                        class="group/user flex items-center gap-1.5 px-3 py-1.5 bg-white/5 hover:bg-white/10 rounded-full transition-all border border-white/5 hover:border-white/10"
                    >
                        <img v-if="remix.user.profile_photo_url" 
                             :src="remix.user.profile_photo_url" 
                             class="w-4 h-4 rounded-full object-cover shadow-sm" />
                        
                        <svg v-else xmlns="http://www.w3.org/2000/svg" class="w-3.5 h-3.5 text-gray-500 group-hover/user:text-indigo-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"></path>
                            <circle cx="12" cy="7" r="4"></circle>
                        </svg>

                        <span class="text-[10px] font-black text-gray-400 group-hover/user:text-white uppercase tracking-tight">
                            {{ remix.user.name }}
                        </span>

                        <svg class="w-2.5 h-2.5 text-gray-600 group-hover/user:text-indigo-400" fill="currentColor" viewBox="0 0 20 20">
                            <path d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" />
                        </svg>
                    </button>

                    <div v-if="activeMenuId === 'match-' + remix.id" 
                        class="absolute left-1/2 -translate-x-1/2 mt-2 w-40 bg-[#252932] border border-white/10 rounded-xl shadow-2xl z-[100] py-2 overflow-hidden animate-in fade-in zoom-in-95 duration-200"
                        @click.stop> 
                        <button 
                            @click.stop="goToProfile(remix.user.id)"
                            class="flex items-center gap-3 w-full px-4 py-2.5 text-[11px] font-black text-gray-300 hover:bg-indigo-600 hover:text-white transition-all text-left"
                        >
                            <span>👤</span> 회원정보 보기
                        </button>
                    </div>
                </div>
                <div v-else class="px-3 py-1.5 bg-white/5 rounded-full border border-white/5 animate-pulse">
                    <span class="text-[9px] font-black text-gray-700 uppercase">Loading...</span>
                </div>
            </div>

            <h3 class="text-xl sm:text-2xl font-black text-white mb-2 tracking-tighter truncate leading-tight group-hover:text-indigo-400 transition-colors">
                {{ remix.track_title }}
            </h3>
            <p class="text-[10px] sm:text-xs text-gray-500 font-bold uppercase tracking-widest">
                {{ remix.artist_name }}
            </p>
        </div>

        <button @click="selectWinner(remix.id)" 
                :disabled="confirmingId !== null"
                class="w-full py-5 rounded-2xl font-black text-sm sm:text-base italic tracking-tighter uppercase transition-all flex items-center justify-center gap-3 relative overflow-hidden"
                :class="confirmingId === remix.id 
                    ? 'bg-indigo-600/20 text-indigo-400 cursor-not-allowed' 
                    : 'bg-white text-black hover:bg-indigo-600 hover:text-white hover:scale-[1.02] active:scale-95 shadow-xl shadow-black/20'">
            
            <template v-if="confirmingId !== remix.id">
                <span>Pick This Vibe</span>
                <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M13 7l5 5m0 0l-5 5m5-5H6" /></svg>
            </template>
            <template v-else>
                <div class="w-5 h-5 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin"></div>
            </template>
        </button>
    </div>
</div>
                    </div>
                </div>

                <div class="mt-20 border-t border-gray-800/50 pt-16">
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-12">
                        <div class="space-y-4">
                            <h4 class="text-indigo-500 font-black text-xs uppercase tracking-[0.2em] italic">01. How to Play</h4>
                            <p class="text-gray-400 text-[11px] font-bold leading-relaxed uppercase tracking-tighter">
                                우측 하단의 <span class="text-white">음소거 아이콘(🔈)</span>을 클릭하여 각 후보의 사운드를 활성화하세요. 두 곡을 충분히 감상하신 후, 더 트렌디한 비트의 <span class="text-indigo-500">PICK THIS VIBE</span> 버튼을 클릭하세요.
                            </p>
                        </div>

                        <div class="space-y-4">
                            <h4 class="text-indigo-500 font-black text-xs uppercase tracking-[0.2em] italic">02. Save Your Vibe</h4>
                            <p class="text-gray-400 text-[11px] font-bold leading-relaxed uppercase tracking-tighter">
                                배틀 도중 마음에 드는 곡을 발견하셨나요? 하단의 <span class="text-white">하트 아이콘(♥)</span>을 누르면 해당 곡이 즉시 <span class="text-indigo-400">MY VIBE 보관함</span>에 저장되어 언제든 다시 감상할 수 있습니다.
                            </p>
                        </div>

                        <div class="space-y-4">
                            <h4 class="text-red-500 font-black text-xs uppercase tracking-[0.2em] italic">03. Policy</h4>
                            <p class="text-gray-400 text-[11px] font-bold leading-relaxed uppercase tracking-tighter">
                                실시간 랭킹의 공정성을 위해 중복 투표나 매크로 사용은 엄격히 금지됩니다. 부적절한 방법으로 점수를 조작할 경우 해당 곡은 <span class="text-red-500">차트에서 영구 제외</span>될 수 있습니다.
                            </p>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </AuthenticatedLayout>
</template>

<style scoped>
/* ✅ VS 위치 및 부유 애니메이션 교정 */
.vs-float {
    animation: floating 3s ease-in-out infinite;
}

@keyframes floating {
    0%, 100% { transform: translateY(0) scale(1); }
    50% { transform: translateY(-10px) scale(1.05); }
}

:deep(iframe) {
    width: 100% !important;
    height: 100% !important;
    position: absolute;
    top: 0;
    left: 0;
}
</style>