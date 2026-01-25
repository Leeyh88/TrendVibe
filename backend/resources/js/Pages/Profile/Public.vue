<script setup>
import { ref } from 'vue';
import { Head, Link, usePage } from '@inertiajs/vue3';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';

const props = defineProps({
    artist: Object,
    posts: Object,   // 일반 게시글
    remixes: Object, // 리믹스 곡 데이터
});

// 현재 활성화된 탭 관리
const activeTab = ref('remixes');

// 모달 관련 상태 및 함수
const isModalOpen = ref(false);
const selectedSong = ref(null);

// 유튜브 URL에서 ID만 추출하는 헬퍼 함수
const extractYoutubeId = (url) => {
    if (!url) return null;
    const regExp = /^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*/;
    const match = url.match(regExp);
    return (match && match[7].length == 11) ? match[7] : null;
};

const remixList = ref([...props.remixes.data]);

const openModal = (remix) => {
    selectedSong.value = {
        ...remix,
        // 만약 remix 객체에 직접적인 ID가 없다면 URL에서 추출
        youtube_video_id: remix.youtube_video_id || extractYoutubeId(remix.youtube_url),
        platform: 'Remix',
        artist: props.artist.name,
        isFavorite: false // 초기값 (실제 데이터에 따라 조정 가능)
    };
    isModalOpen.value = true;
};

const closeModal = () => {
    isModalOpen.value = false;
    selectedSong.value = null;
};

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
            // 1. 모달 내 하트 상태 즉시 반영
            selectedSong.value.isFavorite = res.data.isFavorite;
            
            // 2. 배경 리스트 데이터 동기화 (ref로 선언한 remixList 사용)
            const target = remixList.value.find(r => r.id === song.id);
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
    <Head :title="artist.name + '님의 프로필'" />

    <AuthenticatedLayout>
        <div class="min-h-screen bg-[#fcfcfc] pb-20">
            <div class="h-64 bg-gradient-to-r from-slate-900 via-indigo-950 to-slate-900 relative">
                <div class="absolute inset-0 bg-black/20"></div>
            </div>

            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div class="-mt-32 relative z-10">
                    <div class="bg-white rounded-[2.5rem] shadow-2xl border border-gray-100 overflow-hidden">
                        <div class="p-8 md:p-12">
                            <div class="flex flex-col md:flex-row items-center md:items-end gap-8">
                                <div class="w-44 h-44 rounded-[2.5rem] overflow-hidden border-8 border-white shadow-xl bg-gray-50 flex-shrink-0">
                                    <img v-if="artist.profile_photo_url" :src="artist.profile_photo_url" class="w-full h-full object-cover" />
                                    <div v-else class="w-full h-full flex items-center justify-center text-gray-200">
                                        <svg class="w-20 h-20" fill="currentColor" viewBox="0 0 24 24"><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg>
                                    </div>
                                </div>

                                <div class="flex-1 text-center md:text-left">
                                    <div class="flex flex-wrap justify-center md:justify-start items-center gap-3">
                                        <h1 class="text-4xl font-black text-gray-900 leading-tight">{{ artist.name }}</h1>
                                        <span v-if="artist.daw_info" class="px-3 py-1 bg-indigo-600 text-white rounded-lg text-[10px] font-black uppercase tracking-widest">
                                            {{ artist.daw_info }}
                                        </span>
                                    </div>
                                    <p class="mt-4 text-gray-500 font-medium text-lg max-w-3xl leading-relaxed">
                                        {{ artist.bio || '음악으로 소통하는 아티스트입니다.' }}
                                    </p>
                                    <div v-if="artist.public_email" class="mt-4 flex items-center justify-center md:justify-start gap-2 text-indigo-500 font-bold text-sm">
                                        <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" /></svg>
                                        <a :href="'mailto:' + artist.public_email" class="hover:underline tracking-tight">{{ artist.public_email }}</a>
                                    </div>
                                </div>

                                <div class="hidden lg:flex items-center gap-4">
                                    <div class="bg-amber-50 px-8 py-4 rounded-3xl border border-amber-100 text-center">
                                        <span class="block text-[10px] font-black text-amber-500 uppercase tracking-[0.2em] mb-1">Match Victories</span>
                                        <div class="flex items-baseline justify-center gap-1">
                                            <span class="text-3xl font-black text-amber-600">{{ artist.total_likes || 0 }}</span>
                                            <small class="text-xs text-amber-500 font-bold uppercase">Wins</small>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 mt-12">
                    <div class="lg:col-span-4 space-y-6">
                        <div class="bg-white p-8 rounded-[2rem] shadow-sm border border-gray-100">
                            <h3 class="text-sm font-black text-gray-400 uppercase tracking-[0.2em] mb-6 flex items-center gap-2">
                                <span class="w-1 h-3 bg-indigo-600 rounded-full"></span>
                                Artist Channels
                            </h3>
                            <div class="grid gap-3">
                                <a v-if="artist.soundcloud_url" :href="artist.soundcloud_url" target="_blank" class="flex items-center justify-between p-4 bg-[#fff5ee] rounded-2xl group transition-all hover:bg-[#ffede0]">
                                    <div class="flex items-center gap-3">
                                        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" class="w-7 h-7 fill-[#ff5500]"><path d="M7 16h1v-5.5h-1V16zm2 0h1V9.5h-1V16zm2 0h1V8.5h-1V16zm2 0h1v-7.5h-1V16zm2 0h1v-7.5h-1V16zm2 0h1v-6.5h-1V16zm1.5-7.5c-1.38 0-2.5 1.12-2.5 2.5v5h5.5c1.38 0 2.5-1.12 2.5-2.5s-1.12-2.5-2.5-2.5h-.5v-1.5c0-1.93-1.57-3.5-3.5-3.5-1.55 0-2.85 1.01-3.3 2.4l-.1.35-.35-.05c-.1-.01-.2-.02-.3-.02-1.38 0-2.5 1.12-2.5 2.5V16h1v-7.5z"/></svg>
                                        <span class="text-[#ff5500] font-black">SoundCloud</span>
                                    </div>
                                    <span class="text-[#ff5500]/50 group-hover:translate-x-1 transition-transform font-bold">→</span>
                                </a>

                                <a v-if="artist.youtube_url" :href="artist.youtube_url" target="_blank" class="flex items-center justify-between p-4 bg-[#fff0f0] rounded-2xl group transition-all hover:bg-[#ffe5e5]">
                                    <div class="flex items-center gap-3">
                                        <svg role="img" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" class="w-6 h-6 fill-[#ff0000]"><path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.377.505 9.377.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z"/></svg>
                                        <span class="text-[#ff0000] font-black">YouTube</span>
                                    </div>
                                    <span class="text-[#ff0000]/50 group-hover:translate-x-1 transition-transform font-bold">→</span>
                                </a>

                                <div v-if="artist.public_email" class="p-4 bg-gray-50 rounded-2xl text-[11px] font-bold text-gray-500 truncate border border-gray-100">
                                    📧 {{ artist.public_email }}
                                </div>
                            </div>
                        </div>

                        <div v-if="artist.donation_info" class="bg-indigo-600 p-8 rounded-[2rem] shadow-xl text-white relative overflow-hidden">
                            <div class="relative z-10">
                                <h3 class="text-xxs font-black text-indigo-200 uppercase tracking-[0.2em] mb-4 flex items-center gap-2">
                                    Support Artist
                                </h3>
                                <p class="text-sm leading-relaxed font-medium whitespace-pre-line opacity-95 italic">
                                    "{{ artist.donation_info }}"
                                </p>
                            </div>
                            <svg class="absolute -bottom-4 -right-4 w-32 h-32 text-white/10" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M2 10.5a1.5 1.5 0 113 0v6a1.5 1.5 0 01-3 0v-6zM6 10.333v5.43a2 2 0 001.106 1.79l.05.025A4 4 0 008.943 18h5.416a2 2 0 001.962-1.608l1.2-6A2 2 0 0015.56 8H12V4a2 2 0 00-2-2 1 1 0 00-1 1v.667a4 4 0 01-.8 2.4L6.8 9.333a2 2 0 00-.8 1.001z" />
                            </svg>
                        </div>
                    </div>

                    <div class="lg:col-span-8">
                        <div class="flex items-center p-1.5 bg-gray-100 rounded-[2rem] mb-8 w-fit shadow-inner">
                            <button @click="activeTab = 'remixes'" :class="activeTab === 'remixes' ? 'bg-white text-indigo-600 shadow-sm' : 'text-gray-500 hover:text-gray-700'" class="px-10 py-3 rounded-[1.8rem] text-sm font-black transition-all">
                                Remixes ({{ remixes.total }})
                            </button>
                            <button @click="activeTab = 'posts'" :class="activeTab === 'posts' ? 'bg-white text-indigo-600 shadow-sm' : 'text-gray-500 hover:text-gray-700'" class="px-10 py-3 rounded-[1.8rem] text-sm font-black transition-all">
                                Posts ({{ posts.total }})
                            </button>
                        </div>

                        <div v-if="activeTab === 'remixes'" class="space-y-4">
                            <div v-if="remixes.data.length > 0" class="space-y-4">
                                <div 
                                    v-for="remix in remixes.data" 
                                    :key="remix.id" 
                                    @click="openModal(remix)"
                                    class="flex items-center bg-white p-6 rounded-[2.2rem] border border-gray-100 shadow-sm hover:shadow-xl hover:-translate-y-1 transition-all group cursor-pointer"
                                >
                                    <div class="w-16 h-16 bg-amber-50 rounded-2xl flex items-center justify-center text-amber-500 group-hover:bg-amber-500 group-hover:text-white transition-all shrink-0">
                                        <svg class="w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3" /></svg>
                                    </div>
                                    <div class="ml-6 flex-1">
                                        <h4 class="font-black text-gray-900 text-lg group-hover:text-indigo-600 transition-colors">{{ remix.title }}</h4>
                                        <p class="text-[10px] font-bold text-gray-400 uppercase tracking-widest mt-1">
                                            📅 {{ new Date(remix.created_at).toLocaleDateString() }}
                                        </p>
                                    </div>
                                    <div class="mr-4 opacity-0 group-hover:opacity-100 transition-all translate-x-2 group-hover:translate-x-0">
                                        <svg class="w-6 h-6 text-indigo-600" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M17 8l4 4m0 0l-4 4m4-4H3" /></svg>
                                    </div>
                                </div>
                            </div>
                            <div v-else class="bg-white rounded-[2.5rem] py-32 text-center border-2 border-dashed border-gray-100">
                                <p class="text-gray-300 font-black text-lg uppercase tracking-widest italic">No Remixes Found</p>
                            </div>
                        </div>

                        <div v-if="activeTab === 'posts'" class="space-y-4">
                            <div v-if="posts.data.length > 0" class="space-y-4">
                                <Link v-for="post in posts.data" :key="post.id" :href="route('posts.show', post.id)" class="flex items-center bg-white p-6 rounded-[2.2rem] border border-gray-100 shadow-sm hover:shadow-xl hover:-translate-y-1 transition-all group">
                                    <div class="w-16 h-16 bg-indigo-50 rounded-2xl flex items-center justify-center text-indigo-600 group-hover:bg-indigo-600 group-hover:text-white transition-all shrink-0">
                                        <svg class="w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h10M7 12h10" /></svg>
                                    </div>
                                    <div class="ml-6 flex-1">
                                        <h4 class="font-black text-gray-900 text-lg group-hover:text-indigo-600 transition-colors">{{ post.title }}</h4>
                                        <div class="flex items-center gap-4 mt-1 text-[10px] font-bold text-gray-400 tracking-widest uppercase">
                                            <span>📅 {{ new Date(post.created_at).toLocaleDateString() }}</span>
                                            <span class="flex items-center gap-1">💬 {{ post.comments_count || 0 }}</span>
                                        </div>
                                    </div>
                                    <div class="mr-4 opacity-0 group-hover:opacity-100 transition-all translate-x-2 group-hover:translate-x-0">
                                        <svg class="w-6 h-6 text-indigo-600" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M17 8l4 4m0 0l-4 4m4-4H3" /></svg>
                                    </div>
                                </Link>
                            </div>
                            <div v-else class="bg-white rounded-[2.5rem] py-32 text-center border-2 border-dashed border-gray-100">
                                <p class="text-gray-300 font-black text-lg uppercase tracking-widest italic">No Posts Found</p>
                            </div>
                        </div>

                        

                    </div>
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
                            {{ selectedSong?.platform }} Preview
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