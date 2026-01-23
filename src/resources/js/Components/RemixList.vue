<template>
  <div class="container mx-auto p-6">
    
    <div class="mb-6">
      <div class="relative max-w-md">
        <span class="absolute inset-y-0 left-0 pl-4 flex items-center text-gray-400">
      🔍
    </span>
        <input 
      type="text"
      v-model="searchQuery"
      placeholder="곡 제목이나 아티스트 검색..."
      class="block w-full pl-12 pr-4 py-3 border-none rounded-2xl bg-white shadow-md focus:ring-2 focus:ring-indigo-500 transition-all"
    />
      </div>
    </div>
    
    <div class="flex gap-2 mb-8 overflow-x-auto pb-2">
      <button 
        @click="selectedGenreId = null"
        :class="selectedGenreId === null ? 'bg-indigo-600 text-white' : 'bg-gray-100 text-gray-600'"
        class="px-5 py-2 rounded-full font-medium transition-colors whitespace-nowrap"
      >
        전체
      </button>
      <button
        v-for="genre in genres" :key="genre.id"
        @click="selectedGenreId = genre.id"
        :class="selectedGenreId === genre.id ? 'bg-indigo-600 text-white' : 'bg-gray-100 text-gray-600'"
        class="px-5 py-2 rounded-full font-medium transition-colors whitespace-nowrap"
      >
        {{ genre.name }}
      </button>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
      <div 
        v-for="remix in filteredRemixes" :key="remix.id" 
        @click="openModal(remix.youtube_video_id)"
        class="group bg-white rounded-2xl shadow-sm hover:shadow-2xl transition-all cursor-pointer border border-gray-100 overflow-hidden"
      >
        <div class="relative aspect-video overflow-hidden">
          <img :src="remix.music_track.thumbnail_url" class="w-full h-full object-cover group-hover:scale-105 transition-transform" />
          <div class="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity bg-black/40">
             <div class="bg-white p-3 rounded-full text-indigo-600 shadow-lg">▶️</div>
          </div>
        </div>

        <div class="p-5">
          <h3 class="text-lg font-bold text-gray-900 truncate">{{ remix.title }}</h3>
          <p class="text-gray-500 text-sm mt-2">Original: {{ remix.music_track.artist }}</p>

          <div class="flex justify-between items-center mt-4 pt-4 border-t border-gray-50">
            <button 
              @click.stop="handleVote(remix)" 
              class="group flex items-center gap-2 px-3 py-1.5 rounded-full bg-gray-50 hover:bg-red-50 text-gray-600 hover:text-red-500 transition-colors"
            >
              <span class="group-hover:scale-120 transition-transform">❤️</span>
              <span class="font-bold">{{ remix.vote_count }}</span>
            </button>
            <span class="text-xs text-gray-400">조회수 {{ remix.view_count }}</span>
          </div>
        </div>
      </div>
    </div>

    <div v-if="selectedVideoId" class="fixed inset-0 z-50 flex items-center justify-center bg-black/80 p-4" @click.self="closeModal">
      <div class="relative w-full max-w-4xl aspect-video bg-black rounded-xl overflow-hidden shadow-2xl">
        <button @click="closeModal" class="absolute -top-10 right-0 text-white text-xl font-bold hover:text-gray-300">닫기 [X]</button>
        <iframe 
          class="w-full h-full"
          :src="`https://www.youtube.com/embed/${selectedVideoId}?autoplay=1`" 
          frameborder="0" 
          allow="autoplay; encrypted-media" 
          allowfullscreen
        ></iframe>
      </div>
    </div>

    <div v-if="filteredRemixes.length === 0" class = "text-center py-20">
      <p class="text-gray-400 text-lg">해당 장르의 리믹스가 아직 없네요. </p>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'; 
import axios from 'axios';

const remixes = ref([]);
const genres = ref([]); 
const selectedGenreId = ref(null); 
const selectedVideoId = ref(null);
const searchQuery = ref("");

// 검색 & 필터링 로직
const filteredRemixes = computed(() => {
  return remixes.value.filter(remix => {
      // (1) 장르 매칭 확인
      const isGenreMatch = !selectedGenreId.value || remix.genre_id === selectedGenreId.value;

      // (2) 검색어 매칭 확인
      const titleMatch = remix.title.toLowerCase().includes(searchQuery.value.toLowerCase());
      const artistMatch = remix.music_track?.artist?.toLowerCase().includes(searchQuery.value.toLowerCase());
      
      const isSearchMatch = titleMatch || artistMatch;

    return isGenreMatch && isSearchMatch;
  });
    
});

// API 호출 시 곡정보와 장르도 같이 가져오기
const fetchData = async () => {
    const [remixRes, genreRes] = await Promise.all([
        axios.get('/api/remixes'),
        axios.get('/api/genres')
    ]);
    remixes.value = remixRes.data;
    genres.value = genreRes.data;
};

// 투표
const handleVote = async (remix) => {
  try {
    const response = await axios.post(`/api/remixes/${remix.id}/vote`);
    if (response.data.success) {
      remix.vote_count = response.data.new_count;
    }
  } catch (error) {
    if (error.response) {
      const status = error.response.status;
      const message = error.response.data.message;

      if (status == 401) {
        alert("로그인이 필요한 서비스입니다. 로그인페이지로 이동합니다.");
        window.location.href = '/login';
      } else if (status == 400) {
        alert(message);
      } else {
        console.error("네트워크 에러:", error);
      }
    }
  }
}

const openModal = (videoId) => { selectedVideoId.value = videoId; };
const closeModal = () => { selectedVideoId.value = null; };

onMounted(fetchData); 
</script>