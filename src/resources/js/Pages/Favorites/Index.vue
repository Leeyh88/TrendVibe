<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head, router } from '@inertiajs/vue3';
import { ref, computed, onMounted, onUnmounted } from 'vue';
import axios from 'axios';

// 메뉴 상태 관리
const activeMenuId = ref(null);

const props = defineProps({
    youtubeFavorites: { type: Array, default: () => [] },
    remixFavorites: { type: Array, default: () => [] },
    myRemixes: { type: Array, default: () => [] } // 내가 등록한 리믹스 목록 추가
});

// 상위 카테고리 상태: 'favorites' (보관함) | 'activity' (내 활동)
const mainTab = ref('favorites'); 
// 보관함 내부 탭: 'remix' | 'youtube'
const currentTab = ref('remix'); 

// 메뉴 토글 및 기능 함수들 (기존 유지)
const toggleUserMenu = (event, id) => {
    event.stopPropagation();
    activeMenuId.value = activeMenuId.value === id ? null : id;
};
const goToProfile = (userId) => {
    if (!userId) return;
    activeMenuId.value = null;
    router.visit(`/public-profile/${userId}`);
};
const closeMenu = () => { activeMenuId.value = null; };
onMounted(() => window.addEventListener('click', closeMenu));
onUnmounted(() => window.removeEventListener('click', closeMenu));

// 모달 플레이어 관련 (기존 유지)
const isVideoModalOpen = ref(false);
const selectedSong = ref(null);

const openVideo = (fav, type = null) => {
    if (mainTab.value === 'activity' || type === 'remix_list') {
        selectedSong.value = {
            id: fav.id,
            youtube_video_id: fav.youtube_video_id,
            title: fav.title,
            artist: fav.user?.name || 'My Remix',
            type: 'remix',
        };
    } else if (currentTab.value === 'remix') {
        selectedSong.value = {
            id: fav.track_id,
            youtube_video_id: fav.youtube_video_id,
            title: fav.remix_title,
            artist: fav.artist_name,
            type: 'remix',
        };
    } else {
        selectedSong.value = {
            id: fav.track_id,
            youtube_video_id: fav.track_id,
            title: fav.title,
            artist: 'YouTube Trend',
            type: 'youtube',
        };
    }
    isVideoModalOpen.value = true;
};

// 관심곡 제거
const removeFavorite = (fav) => {
    const title = currentTab.value === 'remix' ? fav.remix_title : fav.title;
    if (confirm(`[${title}] 곡을 보관함에서 삭제하시겠습니까?`)) {
        axios.post('/favorites/toggle', {
            track_id: String(fav.track_id),
            type: currentTab.value,
            title: title
        }).then(() => router.reload({ preserveScroll: true }));
    }
};
</script>

<template>
    <Head title="My Vibe" />

    <AuthenticatedLayout>
        <div class="py-12 bg-[#0F1115] min-h-screen">
            <div class="max-w-6xl mx-auto px-6">
                
                <div class="flex justify-center mb-12">
                    <div class="inline-flex bg-white/5 p-1 rounded-2xl border border-white/10 backdrop-blur-md">
                        <button @click="mainTab = 'favorites'" 
                            class="px-8 py-3 rounded-xl text-xs font-black uppercase tracking-widest transition-all"
                            :class="mainTab === 'favorites' ? 'bg-white text-black shadow-xl' : 'text-gray-500 hover:text-gray-300'">
                            Archive
                        </button>
                        <button @click="mainTab = 'activity'" 
                            class="px-8 py-3 rounded-xl text-xs font-black uppercase tracking-widest transition-all"
                            :class="mainTab === 'activity' ? 'bg-white text-black shadow-xl' : 'text-gray-500 hover:text-gray-300'">
                            Studio
                        </button>
                    </div>
                </div>

                <template v-if="mainTab === 'favorites'">
                    <header class="mb-12 flex flex-col md:flex-row md:items-end justify-between gap-8">
                        <div class="flex items-center gap-4">
                            <div class="w-1.5 h-10 bg-indigo-600 rounded-full shadow-[0_0_15px_rgba(79,70,229,0.5)]"></div>
                            <div>
                                <h1 class="text-3xl font-black text-white tracking-tighter uppercase italic leading-none">My Favorites</h1>
                                <p class="text-gray-500 font-bold uppercase tracking-[0.2em] text-[10px] mt-1">Saved Tracks</p>
                            </div>
                        </div>

                        <div class="flex bg-white/5 p-1.5 rounded-[1.5rem] border border-white/10 backdrop-blur-md">
                            <button @click="currentTab = 'remix'" 
                                class="px-8 py-3 rounded-xl text-xs font-black uppercase tracking-widest transition-all"
                                :class="currentTab === 'remix' ? 'bg-indigo-600 text-white shadow-lg' : 'text-gray-500 hover:text-gray-300'">
                                Remixes ({{ remixFavorites.length }})
                            </button>
                            <button @click="currentTab = 'youtube'" 
                                class="px-8 py-3 rounded-xl text-xs font-black uppercase tracking-widest transition-all"
                                :class="currentTab === 'youtube' ? 'bg-indigo-600 text-white shadow-lg' : 'text-gray-500 hover:text-gray-300'">
                                Trends ({{ youtubeFavorites.length }})
                            </button>
                        </div>
                    </header>

                    <div v-if="(currentTab === 'remix' ? remixFavorites : youtubeFavorites).length > 0" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
                        <div v-for="fav in (currentTab === 'remix' ? remixFavorites : youtubeFavorites)" :key="fav.id" class="group bg-[#1A1D23] rounded-[2.5rem] overflow-hidden border border-white/5 hover:border-indigo-500/50 transition-all duration-500">
                            <div class="relative aspect-video cursor-pointer" @click="openVideo(fav)">
                                <img :src="currentTab === 'remix' ? `https://img.youtube.com/vi/${fav.youtube_video_id}/mqdefault.jpg` : fav.thumbnail" class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-1000" />
                                <div class="absolute inset-0 bg-black/40 group-hover:bg-black/20"></div>
                            </div>
                            <div class="p-8">
                                <h3 class="text-white font-black text-xl truncate mb-4">{{ currentTab === 'remix' ? fav.remix_title : fav.title }}</h3>
                                <div class="flex justify-between items-center">
                                    <span class="text-indigo-400 text-[11px] font-black uppercase tracking-widest">{{ currentTab === 'remix' ? fav.artist_name : 'YouTube Trend' }}</span>
                                    <button @click="removeFavorite(fav)" class="text-white/20 hover:text-red-500 transition-colors">
                                        <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div v-else class="py-20 text-center text-gray-500 font-black uppercase text-xs tracking-widest">No items saved.</div>
                </template>

                <template v-else>
                    <header class="mb-12">
                        <div class="flex items-center gap-4">
                            <div class="w-1.5 h-10 bg-emerald-500 rounded-full shadow-[0_0_15px_rgba(16,185,129,0.5)]"></div>
                            <div>
                                <h1 class="text-3xl font-black text-white tracking-tighter uppercase italic leading-none">My Tracks</h1>
                                <p class="text-gray-500 font-bold uppercase tracking-[0.2em] text-[10px] mt-1">Management & Performance</p>
                            </div>
                        </div>
                    </header>

                    <div v-if="myRemixes.length > 0" class="space-y-4">
                        <div v-for="remix in myRemixes" :key="remix.id" 
                            class="group bg-[#1A1D23] p-6 rounded-[2rem] border border-white/5 hover:border-emerald-500/30 transition-all flex flex-col md:flex-row items-center gap-6">
                            
                            <div class="relative w-full md:w-40 aspect-video rounded-2xl overflow-hidden flex-shrink-0 cursor-pointer" @click="openVideo(remix, 'remix_list')">
                                <img :src="`https://img.youtube.com/vi/${remix.youtube_video_id}/mqdefault.jpg`" class="w-full h-full object-cover group-hover:scale-110 transition-duration-700" />
                                <div class="absolute inset-0 bg-black/40 flex items-center justify-center">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="w-8 h-8 text-white opacity-0 group-hover:opacity-100 transition-opacity" fill="currentColor" viewBox="0 0 24 24"><path d="M8 5v14l11-7z"/></svg>
                                </div>
                            </div>

                            <div class="flex-grow text-center md:text-left">
                                <h3 class="text-white font-black text-lg italic uppercase tracking-tighter mb-1">{{ remix.title }}</h3>
                                <p class="text-gray-500 text-[10px] font-bold uppercase tracking-widest">{{ remix.created_at_human || 'Just now' }} Uploaded</p>
                            </div>

                            <div class="flex gap-4">
                                <div class="bg-white/5 px-6 py-3 rounded-2xl border border-white/5 text-center min-w-[100px]">
                                    <p class="text-emerald-500 font-black text-xl leading-none mb-1">{{ remix.vote_count || 0 }}</p>
                                    <p class="text-gray-600 text-[9px] font-black uppercase tracking-widest">Votes</p>
                                </div>
                                <div class="bg-white/5 px-6 py-3 rounded-2xl border border-white/5 text-center min-w-[100px]">
                                    <p class="text-indigo-400 font-black text-xl leading-none mb-1">{{ remix.favorite_count || 0 }}</p>
                                    <p class="text-gray-600 text-[9px] font-black uppercase tracking-widest">LIKES</p>
                                </div>
                            </div>

                            <!-- <div class="flex gap-2">
                                <button @click="router.visit(`/remixes/${remix.id}/edit`)" 
                                    class="p-4 bg-white/5 rounded-2xl text-gray-400 hover:text-white hover:bg-white/10 transition-all">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" /></svg>
                                </button>
                            </div> -->
                        </div>
                    </div>
                    <div v-else class="py-20 text-center bg-[#1A1D23] rounded-[3rem] border border-dashed border-white/5">
                        <p class="text-gray-500 font-black uppercase text-xs tracking-widest">You haven't uploaded any remixes yet.</p>
                    </div>
                </template>

            </div>
        </div>

        <Transition name="modal">
            <div v-if="isVideoModalOpen && selectedSong" class="fixed inset-0 z-[100] flex items-center justify-center p-4">
                <div class="absolute inset-0 bg-black/95 backdrop-blur-xl" @click="isVideoModalOpen = false"></div>
                <div class="relative bg-[#1A1D23] w-full max-w-3xl rounded-[3.5rem] overflow-hidden border border-white/10 p-10 pt-16">
                    <button @click="isVideoModalOpen = false" class="absolute top-8 right-10 text-white/30 hover:text-white">
                        <svg xmlns="http://www.w3.org/2000/svg" class="w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path d="M6 18L18 6M6 6l12 12" /></svg>
                    </button>
                    <div class="aspect-video bg-black rounded-[2rem] overflow-hidden mb-8">
                        <iframe :src="`https://www.youtube.com/embed/${selectedSong.youtube_video_id}?autoplay=1`" class="w-full h-full" frameborder="0" allowfullscreen></iframe>
                    </div>
                    <div class="text-center">
                        <h3 class="text-2xl font-black text-white italic uppercase">{{ selectedSong.title }}</h3>
                        <p class="text-gray-500 font-bold uppercase tracking-widest mt-2">{{ selectedSong.artist }}</p>
                    </div>
                </div>
            </div>
        </Transition>
    </AuthenticatedLayout>
</template>