<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head, Link, router } from '@inertiajs/vue3';
import { ref, onMounted, onUnmounted } from 'vue';

const activeMenuId = ref(null);

const toggleUserMenu = (event, id) => {
    event.stopPropagation();
    event.preventDefault();
    
    activeMenuId.value = activeMenuId.value === id ? null : id;
}

const goToProfile = (userId) => {
    activeMenuId.value = null;

    router.visit(`/public-profile/${userId}`);
}

const closeMenu = () => {
    activeMenuId.value = null;
};

const props = defineProps({
    posts: Object,
    filters: Object,
    boardStats: Object
});

const searchQuery = ref(props.filters.search || '');

const categories = [
    { name: 'All Feed', value: ''},
    { name: 'General', value: 'general'},
    { name: 'Recommend', value: 'recommend'},
    { name: 'Question', value: 'question'},
];

const filterCategory = (value) => {
    router.get(route('posts.index'), 
        { ...props.filters, category: value, page: 1 }, 
        { preserveState: true, replace: true }
    );
};

const handleSearch = () => {
    router.get(route('posts.index'), 
        { ...props.filters, search: searchQuery.value, page: 1 }, 
        { preserveState: true, replace: true }
    );
};

const getCategoryName = (category) => {
    const names = { general: '자유', recommend: '추천', question: '질문' };
    return names[category] || category;
};

// 컴포넌트가 마운트될 때 전역 클릭 이벤트 리스너 등록
onMounted(() => {
    window.addEventListener('click', closeMenu);
});

// 컴포넌트가 언마운트될 때 리스너 제거 (메모리 누수 방지)
onUnmounted(() => {
    window.removeEventListener('click', closeMenu);
});
</script>

<template>
    <Head title="커뮤니티" />

    <AuthenticatedLayout>
        <div class="py-12 bg-[#F8FAFC] min-h-screen">
            <div class="max-w-6xl mx-auto px-6">
                
                <header class="mb-10 flex flex-col md:flex-row md:items-end justify-between gap-6">
                    <div>
                        <div class="flex items-center gap-2 mb-2">
                            <span class="px-2 py-0.5 bg-indigo-600 text-white text-[10px] font-black rounded uppercase">Mixer Feed</span>
                        </div>
                        <h1 class="text-4xl font-black text-gray-900 tracking-tighter uppercase italic">Community</h1>
                        <p class="text-gray-400 font-bold mt-1 uppercase tracking-widest text-[10px]">Connect with creators, share your insights.</p>
                    </div>
                    
                    <Link :href="route('posts.create')" class="inline-flex items-center px-6 py-3 bg-gray-900 text-white rounded-2xl font-black text-sm shadow-xl shadow-gray-200 hover:bg-indigo-600 hover:-translate-y-1 transition-all uppercase tracking-tight">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M12 4v16m8-8H4" /></svg>
                        Write Story
                    </Link>
                </header>

                <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    
                    <div class="lg:col-span-2 space-y-6">
                        
                        <div class="bg-white p-2 rounded-2xl shadow-sm border border-gray-100 flex items-center gap-1 overflow-x-auto no-scrollbar">
                            <button 
                                v-for="cat in categories" 
                                :key="cat.value"
                                @click="filterCategory(cat.value)"
                                class="px-5 py-2.5 rounded-xl text-[10px] sm:text-xs font-black transition-all whitespace-nowrap uppercase tracking-tighter"
                                :class="[
                                    (props.filters.category === cat.value || (!props.filters.category && cat.value === '')) 
                                        ? 'bg-indigo-600 text-white shadow-md' 
                                        : 'text-gray-400 hover:bg-gray-50'
                                ]"
                            >
                                {{ cat.name }}
                            </button>
                        </div>

                        <div class="bg-white rounded-[2.5rem] shadow-sm border border-gray-100 overflow-hidden">
                            <div class="divide-y divide-gray-50">
                                <div v-for="post in posts.data" :key="post.id" class="p-6 hover:bg-indigo-50/20 transition-all group cursor-pointer relative">
                                    <div class="flex items-start justify-between gap-4">
                                        <div class="flex-grow min-w-0">
                                            <div class="flex items-center gap-2 mb-2 relative">
                                                <span class="text-[10px] font-black text-indigo-500 uppercase tracking-widest">
                                                    {{ getCategoryName(post.category) }}
                                                </span>
                                                <span class="w-1 h-1 bg-gray-200 rounded-full"></span>
                                                
                                                <div class="relative z-30">
                                                    <button 
                                                        @click.stop="toggleUserMenu($event, 'list-' + post.id)"
                                                        class="group/user flex items-center gap-1 px-2 py-0.5 bg-slate-50 hover:bg-indigo-50 rounded-lg transition-all border border-slate-100 hover:border-indigo-100"
                                                    >
                                                        <span class="text-[10px] font-bold text-gray-400 group-hover/user:text-indigo-600 uppercase tracking-tighter">
                                                            {{ post.user.name }}
                                                        </span>
                                                        <svg class="w-2.5 h-2.5 text-gray-300 group-hover/user:text-indigo-400" fill="currentColor" viewBox="0 0 20 20">
                                                            <path d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" />
                                                        </svg>
                                                    </button>

                                                    <div v-if="activeMenuId === 'list-' + post.id" 
                                                        class="absolute left-0 mt-2 w-40 bg-white border border-gray-100 rounded-xl shadow-2xl z-[100] py-1.5 overflow-hidden animate-in fade-in zoom-in-95 duration-200"
                                                        @click.stop>
                                                        <button 
                                                            @click.stop="goToProfile(post.user.id)"
                                                            class="flex items-center gap-2.5 w-full text-left px-3 py-2 text-[10px] font-black text-gray-700 hover:bg-indigo-50 hover:text-indigo-600 transition-all"
                                                        >
                                                            <span>👤</span> 회원정보 보기
                                                        </button>
                                                    </div>
                                                </div>
                                            </div>

                                            <Link :href="route('posts.show', post.id)" class="block text-lg font-black text-gray-900 group-hover:text-indigo-600 transition-colors leading-snug truncate">
                                                {{ post.title }}
                                            </Link>
                                        </div>

                                        <div class="flex flex-col items-end gap-1 flex-shrink-0">
                                            <span class="text-sm font-black text-gray-900 tabular-nums">{{ post.likes_count || 0 }}</span>
                                            <span class="text-[9px] font-black text-gray-300 uppercase tracking-widest">Likes</span>
                                        </div>
                                    </div>

                                    <div class="flex items-center justify-between mt-4 pt-4 border-t border-gray-50">
                                        <div class="flex items-center gap-4">
                                            <div class="flex items-center gap-1 text-[10px] font-bold text-gray-400">
                                                <svg xmlns="http://www.w3.org/2000/svg" class="h-3 w-3" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
                                                {{ post.view_count.toLocaleString() }}
                                            </div>
                                        </div>
                                        <span class="text-[9px] font-bold text-gray-300 uppercase">{{ new Date(post.created_at).toLocaleDateString() }}</span>
                                    </div>
                                </div>
                                <div v-if="posts.data.length === 0" class="py-24 text-center">
                                    <p class="text-gray-300 font-black uppercase tracking-widest">No Stories Found</p>
                                </div>
                            </div>
                        </div>

                        <div class="flex flex-col items-center gap-8 py-4">
                            <div class="relative w-full max-w-sm">
                                <input v-model="searchQuery" @keyup.enter="handleSearch" type="text" placeholder="Search keywords..." class="w-full pl-12 pr-4 py-3.5 bg-white border border-gray-100 rounded-2xl text-xs font-bold focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-all shadow-sm" />
                                <svg @click="handleSearch" xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 absolute left-4 top-1/2 -translate-y-1/2 text-gray-300 cursor-pointer" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" /></svg>
                            </div>
                            <div class="flex items-center gap-1.5">
                                <button v-for="link in posts.links" :key="link.label" v-html="link.label" @click="link.url ? $inertia.get(link.url) : null" class="px-4 py-2 rounded-xl text-xs font-black transition-all" :class="[ link.active ? 'bg-indigo-600 text-white shadow-lg' : 'bg-white text-gray-400 border border-gray-100 hover:bg-gray-50', !link.url ? 'opacity-20 cursor-not-allowed' : '' ]" :disabled="!link.url"></button>
                            </div>
                        </div>
                    </div>

                    <aside class="space-y-8">
                        <div class="bg-gray-900 rounded-[2.5rem] p-8 text-white shadow-xl shadow-indigo-100 relative overflow-hidden">
                            <div class="relative z-10">
                                <h3 class="font-black text-xs uppercase tracking-[0.2em] text-indigo-400 mb-6">Board Info</h3>
                                <div class="grid grid-cols-2 gap-4">
                                    <div>
                                        <p class="text-[9px] font-bold text-white/40 uppercase mb-1">Total Stories</p>
                                        <p class="text-2xl font-black italic tracking-tighter">
                                            {{ boardStats.totalStories }}
                                        </p>
                                    </div>
                                    <div>
                                        <p class="text-[9px] font-bold text-white/40 uppercase mb-1">Today's Stories</p>
                                        <div class="flex items-baseline gap-1">
                                            <p class="text-2xl font-black italic tracking-tighter" :class="boardStats.todayStories > 0 ? 'text-white' : 'text-white/20'">
                                                {{ boardStats.todayStories }}
                                            </p>
                                            <span v-if="boardStats.todayStories > 0" class="text-[10px] font-black text-green-400 uppercase italic">New</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="absolute -right-10 -bottom-10 w-32 h-32 bg-indigo-600 rounded-full blur-[60px] opacity-20"></div>
                        </div>

                        <div class="bg-white rounded-[2.5rem] p-8 border border-gray-100 shadow-sm">
                            <h3 class="font-black text-gray-900 text-[10px] uppercase tracking-widest mb-6 border-b pb-4 italic">Mixer Guidelines</h3>
                            <ul class="space-y-4">
                                <li class="flex gap-3 items-start">
                                    <span class="w-1.5 h-1.5 bg-indigo-500 rounded-full mt-1.5"></span>
                                    <p class="text-[11px] font-bold text-gray-500 leading-relaxed">서로 존중하며 창의적인 리믹스 의견을 공유해주세요.</p>
                                </li>
                                <li class="flex gap-3 items-start">
                                    <span class="w-1.5 h-1.5 bg-indigo-500 rounded-full mt-1.5"></span>
                                    <p class="text-[11px] font-bold text-gray-500 leading-relaxed">'추천' 카테고리에서 리믹스곡을 선택하여 추천해주세요.</p>
                                </li>
                            </ul>
                        </div>
                    </aside>

                </div>
            </div>
        </div>                
    </AuthenticatedLayout>
</template>

<style scoped>
.no-scrollbar::-webkit-scrollbar { display: none; }
.no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
</style>