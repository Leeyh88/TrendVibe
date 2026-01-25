<script setup>
import Tiptap from '@/Components/Tiptap.vue';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head, useForm, Link } from '@inertiajs/vue3';
import { ref, computed } from 'vue';

const props = defineProps({
    remixes: Array // 컨트롤러에서 전달받은 리믹스 목록
});

const form = useForm({
    title: '',
    category: 'general',
    content: '',
    remix_id: null, // 선택된 리믹스 ID 추가
});

// 리믹스 선택 관련 상태
const isModalOpen = ref(false);
const searchQuery = ref('');
const selectedRemix = ref(null);

// 프론트엔드 실시간 필터링 (1번 방식)
const filteredRemixes = computed(() => {
    if (!props.remixes) return [];
    if (!searchQuery.value) return props.remixes;

    const query = searchQuery.value.toLowerCase().trim();

    return props.remixes.filter(r => {
        return (
            (r.title?.toLowerCase().includes(query)) ||       // 리믹스 제목
            (r.user_name?.toLowerCase().includes(query)) ||   // 리믹스 작성자(회원명)
            (r.track_title?.toLowerCase().includes(query)) || // 원곡 제목
            (r.artist_name?.toLowerCase().includes(query))    // 원곡 가수
        );
    });
});

const selectRemix = (remix) => {
    selectedRemix.value = remix;
    form.remix_id = remix.id;
    isModalOpen.value = false;
    searchQuery.value = '';
};

const removeRemix = () => {
    selectedRemix.value = null;
    form.remix_id = null;
};

const submit = () => {
    form.post(route('posts.store'));
};
</script>

<template>
    <Head title="새 글 작성" />

    <AuthenticatedLayout>
        <div class="py-12 bg-[#F8FAFC] min-h-screen">
            <div class="max-w-4xl mx-auto px-6">
                <header class="mb-8 flex flex-col sm:flex-row sm:items-end justify-between gap-4 px-2">
                    <div>
                        <div class="flex items-center gap-2 mb-2">
                            <span class="px-2 py-0.5 bg-indigo-600 text-white text-[10px] font-black rounded uppercase tracking-widest">Creator Studio</span>
                        </div>
                        <h1 class="text-4xl font-black text-gray-900 tracking-tighter uppercase italic leading-none">Post New Story</h1>
                        <p class="text-gray-400 font-bold mt-2 uppercase tracking-widest text-[10px]">Explore, Discuss, and Mix your insights.</p>
                    </div>
                    <Link :href="route('posts.index')" class="inline-flex items-center justify-center gap-2 px-6 py-3 bg-white text-gray-400 rounded-2xl font-black text-xs hover:text-indigo-600 border border-gray-100 shadow-sm uppercase tracking-widest group">
                        Back to List
                    </Link>
                </header>

                <div class="bg-white rounded-[2.5rem] shadow-sm border border-gray-100 overflow-hidden">
                    <form @submit.prevent="submit" class="p-8 lg:p-12 space-y-8">
                        
                        <div class="grid grid-cols-1 lg:grid-cols-4 gap-6">
                            <div class="lg:col-span-1">
                                <label class="block text-[10px] font-black text-gray-400 uppercase tracking-[0.2em] mb-3 ml-1">Category</label>
                                <select v-model="form.category" 
                                        class="w-full bg-gray-50 border-none rounded-2xl py-4 px-5 text-sm font-bold text-gray-700 focus:ring-2 focus:ring-indigo-600 transition-all cursor-pointer appearance-none">
                                    <option value="general">자유게시판</option>
                                    <option value="recommend">리믹스 추천</option>
                                    <option value="question">질문/답변</option>
                                </select>
                            </div>
                            <div class="lg:col-span-3">
                                <label class="block text-[10px] font-black text-gray-400 uppercase tracking-[0.2em] mb-3 ml-1">Story Title</label>
                                <input v-model="form.title" type="text" placeholder="트렌디한 제목을 입력해 주세요"
                                       class="w-full bg-gray-50 border-none rounded-2xl py-4 px-5 text-sm font-bold text-gray-900 focus:ring-2 focus:ring-indigo-600 transition-all" />
                            </div>
                        </div>

                        <div v-if="form.category === 'recommend'" class="space-y-3">
                            <label class="block text-[10px] font-black text-indigo-400 uppercase tracking-[0.2em] mb-3 ml-1">Link Remix Vibe</label>
                            
                            <div v-if="!selectedRemix" 
                                 @click="isModalOpen = true"
                                 class="group cursor-pointer border-2 border-dashed border-gray-100 rounded-[2rem] p-8 flex flex-col items-center justify-center hover:border-indigo-200 hover:bg-indigo-50/30 transition-all">
                                <div class="w-12 h-12 bg-gray-50 rounded-2xl flex items-center justify-center text-gray-300 group-hover:text-indigo-400 group-hover:scale-110 transition-all mb-3">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" /></svg>
                                </div>
                                <p class="text-[11px] font-black text-gray-400 uppercase tracking-widest">추천할 리믹스 곡을 검색하세요</p>
                            </div>

                            <div v-else class="flex items-center justify-between p-4 bg-indigo-50/50 rounded-3xl border border-indigo-100">
                                <div class="flex items-center gap-4">
                                    <img :src="selectedRemix.album_cover_url" class="w-14 h-14 rounded-2xl object-cover shadow-md" />
                                    <div>
                                        <h4 class="text-sm font-black text-gray-900">{{ selectedRemix.title }}</h4>
                                        <p class="text-[10px] font-bold text-indigo-400 uppercase tracking-tight">{{ selectedRemix.artist_name }}</p>
                                    </div>
                                </div>
                                <button @click="removeRemix" type="button" class="px-4 py-2 text-[10px] font-black text-red-400 hover:text-red-600 uppercase">Change</button>
                            </div>
                        </div>

                        <div>
                            <label class="block text-[10px] font-black text-gray-400 uppercase tracking-[0.2em] mb-3 ml-1">Content</label>
                            <div class="rounded-3xl overflow-hidden border border-gray-100 shadow-inner bg-gray-50/30">
                                <Tiptap v-model="form.content" />
                            </div>
                        </div>

                        <div class="flex items-center justify-end gap-6 pt-6 border-t border-gray-50">
                            <Link :href="route('posts.index')" class="text-xs font-black text-gray-400 hover:text-gray-600 uppercase tracking-widest">Cancel</Link>
                            <button type="submit" :disabled="form.processing" class="px-12 py-4 bg-gray-900 text-white rounded-2xl font-black text-sm shadow-xl shadow-gray-100 hover:bg-indigo-600 transition-all disabled:opacity-50 flex items-center gap-3 uppercase tracking-widest">
                                {{ form.processing ? 'Publishing...' : 'Publish Story' }}
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <div v-if="isModalOpen" class="fixed inset-0 z-[100] flex items-center justify-center p-4">
            <div class="absolute inset-0 bg-black/60 backdrop-blur-md" @click="isModalOpen = false"></div>
            <div class="relative bg-white w-full max-w-lg rounded-[2.5rem] overflow-hidden shadow-2xl animate-in fade-in zoom-in duration-300">
                <div class="p-8 border-b border-gray-50">
                    <h3 class="text-xl font-black italic uppercase tracking-tighter mb-4">Select Remix</h3>
                    <input v-model="searchQuery" type="text" placeholder="곡 제목이나 아티스트 검색..." 
                           class="w-full bg-gray-50 border-none rounded-2xl px-6 py-4 text-sm font-bold focus:ring-2 focus:ring-indigo-600" />
                </div>
                <div class="max-h-[350px] overflow-y-auto p-4 space-y-2 no-scrollbar">
                    <div v-for="remix in filteredRemixes" :key="remix.id" @click="selectRemix(remix)"
                        class="flex items-center gap-4 p-4 rounded-3xl hover:bg-indigo-50 cursor-pointer group transition-all border border-transparent hover:border-indigo-100">
                        
                        <div class="relative flex-shrink-0">
                            <img :src="remix.album_cover_url" class="w-14 h-14 rounded-2xl object-cover shadow-sm group-hover:scale-105 transition-transform" />
                            <div class="absolute -bottom-1 -right-1 w-6 h-6 bg-white rounded-full flex items-center justify-center shadow-sm border border-gray-50 text-[10px] font-black italic text-indigo-600">
                                {{ remix.user_name.charAt(0) }}
                            </div>
                        </div>
                        
                        <div class="flex-grow min-w-0">
                            <div class="flex items-center gap-2 mb-0.5">
                                <span class="px-1.5 py-0.5 bg-gray-100 text-gray-500 text-[8px] font-black rounded uppercase tracking-tighter group-hover:bg-indigo-600 group-hover:text-white transition-colors">
                                    by {{ remix.user_name }}
                                </span>
                                <p class="text-xs font-black text-gray-900 truncate group-hover:text-indigo-600">
                                    {{ remix.title }}
                                </p>
                            </div>
                            <p class="text-[10px] font-bold text-gray-400 uppercase tracking-tight truncate">
                                {{ remix.artist_name }} - {{ remix.track_title }}
                            </p>
                        </div>
                        
                        <div class="flex-shrink-0 opacity-0 group-hover:opacity-100 transition-opacity">
                            <div class="w-8 h-8 bg-indigo-600 text-white rounded-full flex items-center justify-center shadow-lg">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
                                </svg>
                            </div>
                        </div>
                    </div>
                </div>
                <button @click="isModalOpen = false" class="w-full py-5 bg-gray-50 text-[10px] font-black text-gray-400 uppercase tracking-widest hover:bg-gray-100 transition-all">Close</button>
            </div>
        </div>
    </AuthenticatedLayout>
</template>

<style scoped>
.no-scrollbar::-webkit-scrollbar { display: none; }
.no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
:deep(.ProseMirror) { min-height: 300px; padding: 1.5rem; outline: none; }
</style>