<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head, useForm, Link } from '@inertiajs/vue3';
import { ref } from 'vue';
import axios from 'axios';
import { debounce } from 'lodash'; // lodash 설치 확인 필요 (npm install lodash)

const props = defineProps({
    genres: Array,
});

const form = useForm({
    title: '',
    youtube_url: '',
    genre_id: '',
    description: '',
    // 마이그레이션한 새 컬럼들
    track_title: '',
    artist_name: '',
    album_cover_url: '',
    itunes_track_id: '',
});

// 검색 관련 상태
const searchQuery = ref('');
const searchResults = ref([]);
const isSearching = ref(false);
const selectedTrack = ref(null); // 선택된 곡 정보를 화면에 보여주기 위함

// iTunes API 검색 (데바운싱 적용)
const searchTracks = debounce(async (query) => {
    if (query.length < 2) {
        searchResults.value = [];
        return;
    }

    isSearching.value = true;
    try {
        const response = await axios.get('https://itunes.apple.com/search', {
            params: {
                term: query,
                entity: 'song',
                limit: 7,
                country: 'KR'
            }
        });
        searchResults.value = response.data.results;
    } catch (error) {
        console.error("곡 검색 실패:", error);
    } finally {
        isSearching.value = false;
    }
}, 300);

// 곡 선택 처리
const selectTrack = (track) => {
    selectedTrack.value = track;
    
    // 폼 데이터 채우기
    form.track_title = track.trackName;
    form.artist_name = track.artistName;
    form.album_cover_url = track.artworkUrl100.replace('100x100bb.jpg', '600x600bb.jpg');
    form.itunes_track_id = track.trackId.toString();

    // 검색창 초기화
    searchQuery.value = '';
    searchResults.value = [];
};

// 선택 취소
const clearSelectedTrack = () => {
    selectedTrack.value = null;
    form.track_title = '';
    form.artist_name = '';
    form.album_cover_url = '';
    form.itunes_track_id = '';
};

const submit = () => {
    form.post(route('remixes.store'));
};
</script>

<template>
    <Head title="리믹스 업로드" />

    <AuthenticatedLayout>
        <div class="py-12 bg-[#F8FAFC] min-h-screen">
            <div class="max-w-4xl mx-auto px-6">
                
                <header class="mb-10 flex flex-col sm:flex-row sm:items-end justify-between gap-6 px-2">
                    <div>
                        <div class="flex items-center gap-2 mb-2">
                            <span class="px-2 py-0.5 bg-indigo-600 text-white text-[10px] font-black rounded uppercase tracking-widest">Artist Studio</span>
                        </div>
                        <h1 class="text-4xl font-black text-gray-900 tracking-tighter uppercase italic leading-none">Upload Remix</h1>
                        <p class="text-gray-400 font-bold mt-2 uppercase tracking-widest text-[10px]">Share your vibe and define the new trend.</p>
                    </div>
                    <Link :href="route('remixes.index')" class="inline-flex items-center justify-center gap-2 px-6 py-3 bg-white text-gray-400 rounded-2xl font-black text-xs hover:text-indigo-600 transition-all border border-gray-100 shadow-sm uppercase tracking-widest group">
                        Back to List
                    </Link>
                </header>

                <div class="bg-white rounded-[2.5rem] shadow-sm border border-gray-100 overflow-hidden">
                    <form @submit.prevent="submit" class="p-8 lg:p-12 space-y-8">
                        
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                            <div class="relative">
                                <label class="block text-[10px] font-black text-gray-400 uppercase tracking-[0.2em] mb-3 ml-1">Original Track</label>
                                
                                <div v-if="!selectedTrack" class="relative group">
                                    <input 
                                        v-model="searchQuery"
                                        @input="searchTracks(searchQuery)"
                                        type="text" 
                                        placeholder="곡 제목 또는 아티스트 검색..." 
                                        class="w-full bg-gray-50 border-none rounded-2xl py-4 px-5 text-sm font-bold text-gray-900 placeholder:text-gray-300 focus:ring-2 focus:ring-indigo-600 transition-all shadow-inner"
                                    />
                                    <div v-if="isSearching" class="absolute right-5 top-1/2 -translate-y-1/2">
                                        <div class="w-4 h-4 border-2 border-indigo-600 border-t-transparent rounded-full animate-spin"></div>
                                    </div>

                                    <div v-if="searchResults.length > 0" class="absolute z-50 w-full mt-2 bg-white border border-gray-100 rounded-2xl shadow-2xl overflow-hidden">
                                        <div 
                                            v-for="track in searchResults" :key="track.trackId"
                                            @click="selectTrack(track)"
                                            class="flex items-center gap-4 p-4 hover:bg-indigo-50 cursor-pointer transition-colors border-b border-gray-50 last:border-none"
                                        >
                                            <img :src="track.artworkUrl60" class="w-10 h-10 rounded-lg object-cover" />
                                            <div class="overflow-hidden">
                                                <p class="text-xs font-black text-gray-900 truncate">{{ track.trackName }}</p>
                                                <p class="text-[9px] font-bold text-gray-400 uppercase">{{ track.artistName }}</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div v-else class="flex items-center gap-4 p-3 bg-indigo-50 rounded-2xl border border-indigo-100 relative group">
                                    <img :src="selectedTrack.artworkUrl60" class="w-12 h-12 rounded-xl object-cover shadow-sm" />
                                    <div class="overflow-hidden pr-8">
                                        <p class="text-xs font-black text-indigo-900 truncate">{{ selectedTrack.trackName }}</p>
                                        <p class="text-[10px] font-bold text-indigo-400 uppercase">{{ selectedTrack.artistName }}</p>
                                    </div>
                                    <button @click="clearSelectedTrack" type="button" class="absolute right-4 top-1/2 -translate-y-1/2 text-indigo-300 hover:text-indigo-600">
                                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M6 18L18 6M6 6l12 12" /></svg>
                                    </button>
                                </div>
                                <p v-if="form.errors.track_title" class="mt-2 text-[10px] text-red-500 font-bold uppercase ml-1 italic">{{ form.errors.track_title }}</p>
                            </div>

                            <div>
                                <label class="block text-[10px] font-black text-gray-400 uppercase tracking-[0.2em] mb-3 ml-1">Genre</label>
                                <div class="relative group">
                                    <select v-model="form.genre_id" 
                                            class="w-full bg-gray-50 border-none rounded-2xl py-4 px-5 text-sm font-bold text-gray-700 focus:ring-2 focus:ring-indigo-600 transition-all cursor-pointer appearance-none">
                                        <option value="" disabled>장르 선택</option>
                                        <option v-for="genre in genres" :key="genre.id" :value="genre.id">{{ genre.name }}</option>
                                    </select>
                                    <div class="absolute right-5 top-1/2 -translate-y-1/2 pointer-events-none text-gray-300">
                                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M19 9l-7 7-7-7" /></svg>
                                    </div>
                                </div>
                                <p v-if="form.errors.genre_id" class="mt-2 text-[10px] text-red-500 font-bold uppercase ml-1 italic">{{ form.errors.genre_id }}</p>
                            </div>
                        </div>

                        <div>
                            <label class="block text-[10px] font-black text-gray-400 uppercase tracking-[0.2em] mb-3 ml-1">Remix Title</label>
                            <input v-model="form.title" type="text" placeholder="예: Hype Boy (TrendVibe Edition)" 
                                   class="w-full bg-gray-50 border-none rounded-2xl py-4 px-5 text-sm font-bold text-gray-900 focus:ring-2 focus:ring-indigo-600 transition-all shadow-inner" />
                            <p v-if="form.errors.title" class="mt-2 text-[10px] text-red-500 font-bold uppercase ml-1 italic">{{ form.errors.title }}</p>
                        </div>

                        <div>
                            <label class="block text-[10px] font-black text-gray-400 uppercase tracking-[0.2em] mb-3 ml-1">YouTube Link</label>
                            <div class="relative">
                                <input v-model="form.youtube_url" type="text" placeholder="https://youtube.com/watch?v=..." 
                                       class="w-full bg-gray-50 border-none rounded-2xl py-4 px-12 text-sm font-bold text-gray-900 focus:ring-2 focus:ring-red-500 transition-all shadow-inner" />
                                <div class="absolute left-5 top-1/2 -translate-y-1/2">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-red-500" fill="currentColor" viewBox="0 0 24 24"><path d="M19.615 3.184c-3.604-.246-11.631-.245-15.23 0-3.897.266-4.356 2.62-4.385 8.816.029 6.185.484 8.549 4.385 8.816 3.6.245 11.626.246 15.23 0 3.897-.266 4.356-2.62 4.385-8.816-.029-6.185-.484-8.549-4.385-8.816zm-10.615 12.816v-8l8 3.993-8 4.007z"/></svg>
                                </div>
                            </div>
                            <p v-if="form.errors.youtube_url" class="mt-2 text-[10px] text-red-500 font-bold uppercase ml-1 italic">{{ form.errors.youtube_url }}</p>
                        </div>

                        <div>
                            <label class="block text-[10px] font-black text-gray-400 uppercase tracking-[0.2em] mb-3 ml-1">About this Remix</label>
                            <textarea v-model="form.description" rows="4" placeholder="작업 의도나 사용된 툴 등 리믹스에 대한 설명을 들려주세요."
                                      class="w-full bg-gray-50 border-none rounded-[1.8rem] py-5 px-6 text-sm font-medium text-gray-700 focus:ring-2 focus:ring-indigo-600 transition-all shadow-inner resize-none"></textarea>
                        </div>

                        <div class="pt-4">
                            <button type="submit" :disabled="form.processing"
                                    class="w-full py-5 bg-gray-900 text-white rounded-2xl font-black text-sm shadow-xl hover:bg-indigo-600 hover:-translate-y-1 transition-all uppercase tracking-widest flex items-center justify-center gap-3">
                                <span v-if="form.processing" class="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></span>
                                {{ form.processing ? 'Publishing...' : 'Publish Remix' }}
                            </button>
                        </div>
                    </form>
                </div>

                <div class="mt-8 px-8 py-6 bg-white rounded-[2rem] border border-gray-100 flex items-start gap-5 shadow-sm">
                    <div class="w-10 h-10 bg-indigo-50 rounded-full flex items-center justify-center flex-shrink-0"><span class="text-lg">📢</span></div>
                    <div>
                        <h4 class="text-[10px] font-black text-gray-900 uppercase tracking-[0.15em] mb-1">Copyright Notice</h4>
                        <p class="text-[11px] font-bold text-gray-400 leading-relaxed uppercase tracking-tighter">
                            리믹스 업로드 시 타인의 저작권을 존중해 주세요. 원곡 정보는 iTunes API를 통해 자동으로 가져옵니다.
                        </p>
                    </div>
                </div>

            </div>
        </div>
    </AuthenticatedLayout>
</template>