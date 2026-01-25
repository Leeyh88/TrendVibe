<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head, Link, usePage, useForm, router } from '@inertiajs/vue3';
import { ref, computed, onMounted, onUnmounted } from 'vue';
import axios from 'axios';

const props = defineProps({
    post: Object,
});

const activeMenuId = ref(null);

const toggleUserMenu = (event, id) => {
    // 이벤트 버블링 차단 (부모 요소의 클릭 이벤트 방지)
    event.stopPropagation();
    event.preventDefault();
    
    // 현재 열린 메뉴와 같으면 닫고, 아니면 새로 켬
    activeMenuId.value = activeMenuId.value === id ? null : id;
    
    console.log("토글된 메뉴 ID:", id);
};

const goToProfile = (userId) => {
    // 이동 전 메뉴를 즉시 닫음
    activeMenuId.value = null;
    
    // 페이지 이동 (URL은 프로젝트 설정에 맞게 조정 가능)
    router.visit(`/public-profile/${userId}`);
};

const closeMenu = () => {
    activeMenuId.value = null;
};

// 마운트 시 클릭 리스너 등록
onMounted(() => {
    window.addEventListener('click', closeMenu);
});

// 언마운트 시 리스너 제거 (성능 최적화)
onUnmounted(() => {
    window.removeEventListener('click', closeMenu);
});

const toggleFavorite = () => {
    const page = usePage();
    if (!page.props.auth.user) {
        if (confirm('로그인이 필요한 기능입니다. 로그인 페이지로 이동하시겠습니까??')) {
            router.get(route('login'));
        }
        return;
    }

    const remix = props.post.remix;

    axios.post('/favorites/toggle', {
        'track_id': String(remix.id),
        'type': 'remix',
        'title': remix.title,
        'thumbnail': remix.album_cover_url,
    })
    .then(res => {
        // 실시간으로 상태 업데이트
        remix.isFavorite = res.data.isFavorite;
    })
    .catch(err => {
        console.error('오류 발생:', err);
    });
}

const page = usePage();
const user = computed(() => page.props.auth.user);
const isAuthor = computed(() => user.value && user.value.id === props.post.user_id);

const commentForm = useForm({ content: '' });
const replyForm = useForm({ content: '', parent_id: null });
const replyingTo = ref(null);

const submitComment = () => {
    commentForm.post(route('posts.comments.store', props.post.id), {
        preserveScroll: true,
        onSuccess: () => commentForm.reset(),
    });
};

const deleteComment = (commentId) => {
    if (confirm('댓글을 삭제하시겠습니까?')) {
        router.delete(route('comments.destroy', commentId), { preserveScroll: true });
    }
};

const deletePost = () => {
    if (confirm('정말로 이 게시글을 삭제하시겠습니까?')) {
        router.delete(route('posts.destroy', props.post.id));
    }
};

const sharePost = () => {
    if (navigator.share) {
        navigator.share({ title: props.post.title, url: window.location.href });
    } else {
        navigator.clipboard.writeText(window.location.href);
        alert('주소가 복사되었습니다.');
    }
};

const toggleReply = (commentId) => {
    replyingTo.value = replyingTo.value === commentId ? null : commentId;
    replyForm.parent_id = replyingTo.value;
};

const submitReply = (parentId) => {
    replyForm.post(route('posts.comments.store', props.post.id), {
        preserveScroll: true,
        onSuccess: () => { replyingTo.value = null; replyForm.reset(); },
    });
};

const toggleLike = () => {
    router.post(route('posts.like', props.post.id), {}, { preserveScroll: true });
};

const getCategoryName = (category) => {
    const names = { general: '자유', recommend: '추천', question: '질문' };
    return names[category] || category;
};
</script>

<template>
    <Head :title="post.title" />

    <AuthenticatedLayout>
        <div class="py-12 bg-[#F8FAFC] min-h-screen">
            <div class="max-w-4xl mx-auto px-6">
                
                <header class="mb-8 flex items-center justify-between px-2">
                    <div class="flex items-center gap-3">
                        <div class="w-1 h-8 bg-indigo-600 rounded-full"></div>
                        <div>
                            <h1 class="text-2xl font-black text-gray-900 tracking-tighter uppercase italic">Read Story</h1>
                            <p class="text-[10px] text-gray-400 font-bold uppercase tracking-widest">Inspiration Mix</p>
                        </div>
                    </div>
                    <Link :href="route('posts.index')" class="px-5 py-2.5 bg-white border border-gray-100 rounded-2xl text-[10px] font-black text-gray-400 hover:text-indigo-600 hover:border-indigo-100 shadow-sm transition-all uppercase tracking-widest group">
                        <span class="flex items-center gap-2">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-3 w-3 group-hover:-translate-x-1 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M10 19l-7-7m0 0l7-7m-7 7h18" /></svg>
                            Back to Feed
                        </span>
                    </Link>
                </header>

                <article class="bg-white rounded-[2.5rem] shadow-sm border border-gray-100 overflow-hidden mb-8">
                    <div class="p-8 lg:p-12 border-b border-gray-50">
                        <div class="flex items-center gap-3 mb-6">
                            <span class="px-3 py-1 bg-indigo-600 text-white rounded-lg text-[10px] font-black uppercase tracking-widest">
                                {{ getCategoryName(post.category) }}
                            </span>
                            <span class="text-gray-300 text-[11px] font-bold uppercase tracking-tighter italic">
                                Published {{ new Date(post.created_at).toLocaleDateString() }}
                            </span>
                        </div>

                        <h1 class="text-3xl lg:text-5xl font-black text-gray-900 mb-10 leading-[1.15] tracking-tight">
                            {{ post.title }}
                        </h1>

                        <div class="flex items-center justify-between pt-8 border-t border-gray-50">
                            <div class="flex items-center gap-4 relative">
                                <button 
                                    @click.stop="toggleUserMenu($event, 'detail-' + post.user.id)"
                                    class="flex items-center gap-4 group/user text-left outline-none"
                                >
                                    <div class="w-14 h-14 bg-gray-900 rounded-2xl flex items-center justify-center text-white shadow-lg shadow-gray-200 overflow-hidden group-hover/user:scale-105 transition-transform duration-300">
                                        <img v-if="post.user.profile_photo_url" 
                                            :src="post.user.profile_photo_url" 
                                            class="w-full h-full object-cover" />
                                        <svg v-else xmlns="http://www.w3.org/2000/svg" class="w-8 h-8 text-gray-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" />
                                        </svg>
                                    </div>

                                    <div>
                                        <div class="flex items-center gap-1.5 mb-1">
                                            <p class="text-lg font-black text-gray-900 tracking-tight leading-none group-hover/user:text-indigo-600 transition-colors">
                                                {{ post.user.name }}
                                            </p>
                                            <svg class="w-4 h-4 text-gray-300 group-hover/user:text-indigo-400 transition-colors" fill="currentColor" viewBox="0 0 20 20">
                                                <path d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" />
                                            </svg>
                                        </div>
                                        <p class="text-[10px] text-indigo-500 font-black uppercase tracking-widest">Mixer Pro</p>
                                    </div>
                                </button>

                                <div v-if="activeMenuId === 'detail-' + post.user.id" 
                                    class="absolute left-0 top-full mt-3 w-44 bg-white border border-gray-100 rounded-2xl shadow-2xl z-[50] py-2 overflow-hidden animate-in fade-in zoom-in-95 duration-200"
                                    @click.stop>
                                    <button 
                                        @click.stop="goToProfile(post.user.id)"
                                        class="flex items-center gap-3 w-full px-4 py-2.5 text-[11px] font-black text-gray-700 hover:bg-indigo-50 hover:text-indigo-600 transition-all text-left"
                                    >
                                        <span class="text-sm">👤</span> 회원정보 보기
                                    </button>
                                    <div class="h-[1px] bg-gray-50 mx-2 my-1"></div>
                                    <button class="flex items-center gap-3 w-full px-4 py-2.5 text-[11px] font-black text-gray-300 cursor-not-allowed text-left border-none outline-none">
                                        <span class="text-sm">🔔</span> 팔로우 (준비중)
                                    </button>
                                </div>
                            </div> <div class="text-right">
                                <span class="block text-2xl font-black text-gray-900 leading-none mb-1 tabular-nums">{{ post.view_count || 0 }}</span>
                                <span class="text-[9px] font-black text-gray-300 uppercase tracking-[0.2em]">Total Views</span>
                            </div>
                        </div>
                    </div>

                    <div v-if="post.category === 'recommend' && post.remix" class="mb-12">
    <div class="bg-gray-900 rounded-[2.5rem] overflow-hidden shadow-2xl shadow-indigo-100 border border-gray-800">
        <div class="relative aspect-video w-full bg-black">
            <iframe 
                :src="`https://www.youtube.com/embed/${post.remix.youtube_video_id}?rel=0`" 
                class="absolute inset-0 w-full h-full"
                frameborder="0" 
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                allowfullscreen
            ></iframe>
        </div>
        
        <div class="p-6 sm:p-8 flex items-center justify-between bg-gradient-to-r from-gray-900 via-gray-800 to-indigo-950">
            <div class="flex items-center gap-5">
                <div class="relative flex-shrink-0">
                    <img :src="post.remix.album_cover_url" class="w-16 h-16 rounded-2xl object-cover border border-white/10 shadow-2xl" />
                    <div class="absolute -top-2 -right-2 w-6 h-6 bg-indigo-600 rounded-full flex items-center justify-center border-2 border-gray-900">
                        <svg class="w-3 h-3 text-white fill-current" viewBox="0 0 24 24"><path d="M8 5v14l11-7z"/></svg>
                    </div>
                </div>
                
                <div class="min-w-0">
                    <div class="flex items-center gap-2 mb-1">
                        <span class="px-2 py-0.5 bg-indigo-500/20 text-indigo-400 text-[9px] font-black rounded uppercase tracking-widest border border-indigo-500/30">{{ post.remix.user.name }}</span>
                    </div>
                    <h3 class="text-white font-black text-lg truncate leading-tight">{{ post.remix.title }}</h3>
                    <p class="text-gray-400 text-[11px] font-bold uppercase tracking-tight truncate">
                        {{ post.remix.artist_name }} — {{ post.remix.track_title }}
                    </p>
                </div>
            </div>

            <!-- <Link :href="route('remixes.index')" class="hidden md:flex items-center justify-center w-12 h-12 bg-white/5 hover:bg-white/10 rounded-2xl border border-white/10 transition-all group">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-400 group-hover:text-white transition-colors" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M13 7l5 5m0 0l-5 5m5-5H6" />
                </svg>
            </Link> -->

            <button 
                @click="toggleFavorite" 
                class="flex items-center justify-center w-12 h-12 rounded-2xl border transition-all group"
                :class="post.remix.isFavorite 
                    ? 'bg-indigo-600 border-indigo-500 shadow-lg shadow-indigo-500/20' 
                    : 'bg-white/5 border-white/10 hover:bg-white/10'"
            >
                <svg 
                    xmlns="http://www.w3.org/2000/svg" 
                    class="h-5 w-5 transition-all duration-300" 
                    :class="post.remix.isFavorite ? 'text-white fill-current scale-110' : 'text-gray-400 group-hover:text-white'"
                    viewBox="0 0 24 24" 
                    fill="none" 
                    stroke="currentColor" 
                    stroke-width="2.5"
                >
                    <path stroke-linecap="round" stroke-linejoin="round" d="M21 8.25c0-2.485-2.099-4.5-4.688-4.5-1.935 0-3.597 1.126-4.312 2.733-.715-1.607-2.377-2.733-4.313-2.733C5.1 3.75 3 5.765 3 8.25c0 7.22 9 12 9 12s9-4.78 9-12z" />
                </svg>
            </button>
        </div>
    </div>
    
    <div class="mt-12 flex items-center gap-4">
        <div class="flex-grow h-px bg-gray-100"></div>
        <span class="text-[10px] font-black text-gray-300 uppercase tracking-[0.3em]">Story Content</span>
        <div class="flex-grow h-px bg-gray-100"></div>
    </div>
</div>

                    <div class="p-8 lg:p-14">
                        <div class="prose max-w-none text-gray-700 leading-[1.9] text-lg whitespace-pre-wrap font-medium" v-html="post.content"></div>
                    </div>

                    <div class="px-8 py-10 bg-[#FBFBFF] border-t border-gray-50 flex flex-col items-center">
                        <button @click="toggleLike" class="group flex flex-col items-center gap-4 transition-all active:scale-95 mb-4">
                            <div :class="post.is_liked ? 'bg-indigo-600 border-indigo-400 shadow-indigo-200 scale-110' : 'bg-white border-gray-100 text-gray-300 hover:border-indigo-200 hover:text-indigo-400'"
                                 class="w-24 h-24 rounded-[2.5rem] border-2 flex items-center justify-center shadow-xl transition-all duration-500">
                                <svg xmlns="http://www.w3.org/2000/svg" :class="post.is_liked ? 'fill-white' : 'fill-none'" class="h-10 w-10 stroke-current stroke-2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" /></svg>
                            </div>
                            <div class="text-center">
                                <span :class="post.is_liked ? 'text-indigo-600' : 'text-gray-400'" class="text-2xl font-black italic tracking-tighter tabular-nums">{{ post.likes_count || 0 }}</span>
                                <p class="text-[10px] font-black text-gray-300 uppercase tracking-widest mt-1">Likes for this story</p>
                            </div>
                        </button>

                        <div class="flex items-center gap-8 mt-6">
                            <template v-if="isAuthor">
                                <Link :href="route('posts.edit', post.id)" class="text-[11px] font-black text-gray-400 hover:text-indigo-600 uppercase tracking-widest border-b border-transparent hover:border-indigo-600 transition-all">Edit Post</Link>
                                <button @click="deletePost" class="text-[11px] font-black text-red-300 hover:text-red-500 uppercase tracking-widest border-b border-transparent hover:border-red-500 transition-all">Delete Post</button>
                            </template>
                            <button @click="sharePost" class="flex items-center gap-2 px-6 py-3 bg-white border border-gray-100 rounded-2xl text-[11px] font-black text-gray-500 hover:text-indigo-600 shadow-sm transition-all active:scale-95 uppercase tracking-widest">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z" /></svg>
                                Share Mix
                            </button>
                        </div>
                    </div>
                </article>

                <section class="bg-white rounded-[2.5rem] shadow-sm border border-gray-100 p-8 lg:p-12">
                    <h3 class="text-xl font-black text-gray-900 mb-10 italic uppercase tracking-tighter flex items-center gap-3">
                        <span class="w-2 h-2 bg-indigo-600 rounded-full animate-pulse"></span>
                        Discussions <span class="text-indigo-600 tabular-nums">{{ post.comments?.length || 0 }}</span>
                    </h3>

                    <form @submit.prevent="submitComment" class="mb-14 relative group">
                        <textarea v-model="commentForm.content" placeholder="Share your vibe on this story..."
                                  class="w-full border-gray-50 rounded-[2rem] p-8 pr-28 focus:ring-2 focus:ring-indigo-500 focus:border-transparent min-h-[160px] transition-all bg-gray-50/50 resize-none font-bold text-gray-700 placeholder:text-gray-300 shadow-inner"></textarea>
                        <button type="submit" :disabled="commentForm.processing || !commentForm.content"
                                class="absolute bottom-8 right-8 px-8 py-4 bg-gray-900 text-white rounded-2xl font-black text-xs hover:bg-indigo-600 disabled:opacity-20 transition-all shadow-xl shadow-gray-200 uppercase tracking-widest">
                            Post Mix
                        </button>
                    </form>

                    <div class="space-y-12">
                        <div v-for="comment in post.comments" :key="comment.id" class="group/item">
                            <div class="flex gap-6">
                                <div class="w-12 h-12 bg-indigo-50 rounded-2xl flex-shrink-0 flex items-center justify-center font-black text-indigo-400 text-lg italic border border-indigo-100 shadow-sm">
                                    {{ comment.user.name[0] }}
                                </div>
                                <div class="flex-1 min-w-0">
                                    <div class="flex items-center justify-between mb-3">
                                        <div class="flex items-center gap-3">
                                            <span class="font-black text-gray-900 text-[13px] tracking-tight">{{ comment.user.name }}</span>
                                            <span class="text-[9px] text-gray-300 font-bold uppercase tracking-widest">{{ new Date(comment.created_at).toLocaleDateString() }}</span>
                                        </div>
                                        <div class="flex items-center gap-4">
                                            <button @click="toggleReply(comment.id)" class="text-[9px] font-black text-indigo-500 hover:text-indigo-700 uppercase tracking-widest">
                                                {{ replyingTo === comment.id ? 'Cancel' : 'Reply' }}
                                            </button>
                                            <button v-if="user && user.id === comment.user_id" @click="deleteComment(comment.id)" class="text-[9px] font-black text-red-200 hover:text-red-500 opacity-0 group-hover/item:opacity-100 transition-all uppercase tracking-widest">
                                                Delete
                                            </button>
                                        </div>
                                    </div>
                                    <div class="bg-gray-50/50 rounded-3xl rounded-tl-none p-6 text-gray-700 text-[15px] font-medium leading-relaxed shadow-sm border border-gray-100/50">
                                        {{ comment.content }}
                                    </div>

                                    <div v-if="replyingTo === comment.id" class="mt-6 ml-4">
                                        <form @submit.prevent="submitReply(comment.id)" class="relative">
                                            <textarea v-model="replyForm.content" placeholder="Reply to this mixer..." 
                                                      class="w-full border-indigo-50 rounded-[1.8rem] p-5 pr-24 focus:ring-2 focus:ring-indigo-400 bg-white shadow-sm resize-none text-sm font-bold min-h-[110px]"></textarea>
                                            <button type="submit" class="absolute bottom-5 right-5 px-5 py-2.5 bg-indigo-600 text-white rounded-xl font-black text-[10px] shadow-lg shadow-indigo-100 uppercase tracking-widest">
                                                Submit
                                            </button>
                                        </form>
                                    </div>

                                    <div v-if="comment.replies?.length" class="mt-8 space-y-6 ml-4 pl-6 border-l-2 border-indigo-50">
                                        <div v-for="reply in comment.replies" :key="reply.id" class="group/reply">                                            
                                            <div class="flex items-center justify-between mb-2">
                                                <div class="flex items-center gap-3">
                                                    <div class="w-7 h-7 bg-white border border-indigo-100 rounded-xl flex items-center justify-center font-black text-indigo-500 text-[10px] italic">
                                                        {{ reply.user.name[0] }}
                                                    </div>
                                                    <span class="font-black text-gray-900 text-xs tracking-tight">{{ reply.user.name }}</span>
                                                    <span class="text-[8px] text-gray-300 font-bold uppercase tracking-widest">{{ new Date(reply.created_at).toLocaleDateString() }}</span>
                                                </div>
                                                <button v-if="user && user.id === reply.user_id" @click="deleteComment(reply.id)" class="opacity-0 group-hover/reply:opacity-100 text-[8px] font-black text-red-200 hover:text-red-500 uppercase">
                                                    Delete
                                                </button>
                                            </div>
                                            <div class="bg-indigo-50/20 rounded-2xl rounded-tl-none p-4 text-gray-700 text-[13px] font-medium leading-relaxed border border-indigo-100/30">
                                                {{ reply.content }}
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>

                <div class="mt-12 text-center p-10 bg-indigo-900 rounded-[2.5rem] shadow-2xl relative overflow-hidden group">
                    <div class="relative z-10">
                        <h4 class="text-white text-xl font-black italic tracking-tighter mb-4 uppercase">Found this story inspiring?</h4>
                        <p class="text-indigo-200 text-xs font-bold uppercase tracking-[0.2em] mb-8 opacity-70">Mix your thoughts and join the trending discussions.</p>
                        <Link :href="route('posts.index')" class="px-8 py-4 bg-white text-indigo-900 rounded-2xl font-black text-xs hover:bg-indigo-50 transition-all shadow-xl uppercase tracking-widest inline-block">
                            Explore More Feed
                        </Link>
                    </div>
                    <div class="absolute top-0 right-0 w-32 h-32 bg-indigo-500 rounded-full blur-[60px] opacity-20 -mr-16 -mt-16 group-hover:scale-150 transition-transform duration-700"></div>
                </div>

            </div>
        </div>
    </AuthenticatedLayout>
</template>

<style scoped>
.prose { word-break: break-word; }
/* Tiptap 에디터 출력 스타일 최적화 */
:deep(.prose blockquote) { border-left: 4px solid #6366f1; font-style: italic; background: #f8faff; padding: 1rem 2rem; border-radius: 1rem; }
:deep(.prose img) { border-radius: 2rem; box-shadow: 0 10px 30px -10px rgba(0,0,0,0.1); }
</style>