<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { ref } from 'vue';
import { Head, Link } from '@inertiajs/vue3';

import DeleteUserForm from './Partials/DeleteUserForm.vue';
import UpdatePasswordForm from './Partials/UpdatePasswordForm.vue';
import UpdateProfileInformationForm from './Partials/UpdateProfileInformationForm.vue';

defineProps({
    mustVerifyEmail: { type: Boolean },
    status: { type: String },
    myPosts: Array,
    likedPosts: Array,
});

const activeTab = ref('myPosts');
</script>

<template>
    <Head title="프로필 설정" />

    <AuthenticatedLayout>
        <div class="py-12 bg-[#F8FAFC] min-h-screen">
            <div class="max-w-6xl mx-auto px-6">
                
                <header class="mb-10 flex flex-col md:flex-row md:items-end justify-between gap-6 px-2">
                    <div>
                        <div class="flex items-center gap-2 mb-2">
                            <span class="px-2 py-0.5 bg-indigo-600 text-white text-[10px] font-black rounded uppercase tracking-wider">My Account</span>
                        </div>
                        <h1 class="text-4xl font-black text-gray-900 tracking-tighter uppercase italic leading-none">Profile Settings</h1>
                        <p class="text-gray-400 font-bold mt-2 uppercase tracking-widest text-[10px]">Manage your identity and mix your activities.</p>
                    </div>
                </header>

                <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    
                    <div class="lg:col-span-2 space-y-8">
                        
                        <div class="p-8 sm:p-10 bg-white rounded-[2.5rem] shadow-sm border border-gray-100">
                            <div class="flex items-center gap-3 mb-8">
                                <div class="w-10 h-10 bg-indigo-50 rounded-2xl flex items-center justify-center text-indigo-600 shadow-inner">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" /></svg>
                                </div>
                                <h3 class="text-xl font-black text-gray-900 tracking-tight italic uppercase">General Info</h3>
                            </div>
                            <UpdateProfileInformationForm
                                :must-verify-email="mustVerifyEmail"
                                :status="status"
                                class="max-w-full"
                            />
                        </div>

                        <div class="p-8 sm:p-10 bg-white rounded-[2.5rem] shadow-sm border border-gray-100">
                            <div class="flex items-center gap-3 mb-8">
                                <div class="w-10 h-10 bg-amber-50 rounded-2xl flex items-center justify-center text-amber-600 shadow-inner">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" /></svg>
                                </div>
                                <h3 class="text-xl font-black text-gray-900 tracking-tight italic uppercase">Security</h3>
                            </div>
                            <UpdatePasswordForm class="max-w-full" />
                        </div>

                        <div class="p-8 sm:p-10 bg-white rounded-[2.5rem] shadow-sm border border-gray-100 opacity-80 hover:opacity-100 transition-opacity">
                            <div class="flex items-center gap-3 mb-8 text-red-500">
                                <div class="w-10 h-10 bg-red-50 rounded-2xl flex items-center justify-center shadow-inner">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg>
                                </div>
                                <h3 class="text-xl font-black tracking-tight italic uppercase">Danger Zone</h3>
                            </div>
                            <DeleteUserForm class="max-w-full" />
                        </div>
                    </div>

                    <aside class="space-y-8">
                        <div class="bg-white rounded-[2.5rem] p-8 shadow-sm border border-gray-100 sticky top-8">
                            <header class="mb-8">
                                <h2 class="text-sm font-black text-gray-900 uppercase tracking-widest flex items-center gap-2 italic">
                                    <span class="w-1.5 h-6 bg-indigo-600 rounded-full"></span>
                                    My Activity
                                </h2>
                                <p class="mt-2 text-[10px] text-gray-400 font-bold uppercase tracking-widest">Manage your posts and vibes.</p>
                            </header>

                            <div class="flex items-center gap-1 mb-8 bg-gray-50 p-1.5 rounded-2xl overflow-hidden">
                                <button 
                                    @click="activeTab = 'myPosts'"
                                    :class="activeTab === 'myPosts' ? 'bg-white text-indigo-600 shadow-sm' : 'text-gray-400 hover:text-gray-600'"
                                    class="flex-1 py-2.5 rounded-xl text-[10px] font-black transition-all uppercase tracking-tighter"
                                >
                                    My Feed <span class="ml-1 opacity-50">{{ myPosts?.length || 0 }}</span>
                                </button>
                                <button 
                                    @click="activeTab = 'likedPosts'"
                                    :class="activeTab === 'likedPosts' ? 'bg-white text-pink-500 shadow-sm' : 'text-gray-400 hover:text-gray-600'"
                                    class="flex-1 py-2.5 rounded-xl text-[10px] font-black transition-all uppercase tracking-tighter"
                                >
                                    Liked <span class="ml-1 opacity-50">{{ likedPosts?.length || 0 }}</span>
                                </button>
                            </div>

                            <div class="space-y-4 max-h-[500px] overflow-y-auto no-scrollbar">
                                <template v-if="activeTab === 'myPosts'">
                                    <div v-for="post in myPosts" :key="post.id" 
                                        class="group flex flex-col p-4 bg-gray-50/50 rounded-2xl hover:bg-indigo-50/30 border border-transparent hover:border-indigo-100 transition-all">
                                        <Link :href="route('posts.show', post.id)" class="text-xs font-black text-gray-900 group-hover:text-indigo-600 transition-colors line-clamp-1 mb-2">
                                            {{ post.title }}
                                        </Link>
                                        <div class="flex items-center justify-between text-[9px] text-gray-400 font-bold uppercase tracking-widest">
                                            <span>Views {{ post.view_count }}</span>
                                            <span>{{ new Date(post.created_at).toLocaleDateString() }}</span>
                                        </div>
                                    </div>
                                    <div v-if="myPosts.length === 0" class="py-12 text-center text-gray-300 font-black text-[10px] uppercase">No posts yet.</div>
                                </template>

                                <template v-if="activeTab === 'likedPosts'">
                                    <div v-for="post in likedPosts" :key="post.id" 
                                        class="group flex items-center justify-between p-4 bg-gray-50/50 rounded-2xl hover:bg-pink-50/30 border border-transparent hover:border-pink-100 transition-all">
                                        <div class="flex-1 min-w-0">
                                            <Link :href="route('posts.show', post.id)" class="text-xs font-black text-gray-900 group-hover:text-pink-500 transition-colors line-clamp-1 mb-1">
                                                {{ post.title }}
                                            </Link>
                                            <span class="text-[9px] text-gray-400 font-bold uppercase tracking-tighter">By {{ post.user?.name }}</span>
                                        </div>
                                        <div class="text-pink-400 animate-pulse text-xs">♥</div>
                                    </div>
                                    <div v-if="likedPosts.length === 0" class="py-12 text-center text-gray-300 font-black text-[10px] uppercase">No likes yet.</div>
                                </template>
                            </div>
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