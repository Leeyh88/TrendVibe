<script setup>
import { ref } from 'vue';
import ApplicationLogo from '@/Components/ApplicationLogo.vue';
import Dropdown from '@/Components/Dropdown.vue';
import DropdownLink from '@/Components/DropdownLink.vue';
import NavLink from '@/Components/NavLink.vue';
import ResponsiveNavLink from '@/Components/ResponsiveNavLink.vue';
import { Link, useForm } from '@inertiajs/vue3';

const showingNavigationDropdown = ref(false);

// --- 관리자 문의 모달 상태 및 폼 설정 ---
const isContactModalOpen = ref(false);
const contactForm = useForm({
    email: '',
    message: '',
});

const submitContact = () => {
    contactForm.post(route('contact.store'), {
        preserveScroll: true,
        onSuccess: () => {
            isContactModalOpen.value = false;
            contactForm.reset();
            alert('관리자에게 소중한 의견이 전달되었습니다!');
        },
    });
};
</script>

<template>
    <div>
        <div class="min-h-screen bg-gray-100">
            <nav class="sticky top-0 z-50 border-b border-gray-100 bg-white/80 backdrop-blur-md shadow-sm">
                <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
                    <div class="flex h-16 justify-between">
                        <div class="flex">
                            <div class="flex shrink-0 items-center pr-2">
                                <Link :href="route('home')" class="flex items-center group tracking-tighter">
                                    <span class="text-2xl font-black text-gray-900 group-hover:text-indigo-600 transition-all duration-300">
                                        trend<span class="text-indigo-600 group-hover:text-gray-900">Vibe</span>
                                    </span>
                                    <span class="ml-1 w-1.5 h-1.5 bg-indigo-600 rounded-full animate-pulse"></span>
                                </Link>
                            </div>

                            <div class="hidden space-x-6 sm:-my-px sm:ms-10 min-[835px]:flex items-center">
                                <NavLink :href="route('rankings')" :active="route().current('rankings')">순위</NavLink>

                                <Link :href="route('mixmatch')" 
                                      :class="route().current('mixmatch') ? 'bg-gray-900 text-white shadow-lg' : 'bg-gray-200 text-gray-600 hover:bg-gray-300'"
                                      class="px-4 py-1.5 rounded-full text-[11px] font-black uppercase tracking-tighter transition-all flex items-center gap-1.5 border border-transparent">
                                    <span class="w-1.5 h-1.5 bg-red-500 rounded-full animate-pulse"></span>
                                    믹스매치
                                </Link>

                                <NavLink :href="route('posts.index')" :active="route().current('posts.*')">커뮤니티</NavLink>
                                <NavLink :href="route('trends')" :active="route().current('trends')">핫트렌드</NavLink>
                                <NavLink :href="route('remixes.index')" :active="route().current('remixes.index')">리믹스</NavLink>

                                <Link :href="route('favorites.index')" 
                                      :class="route().current('favorites.index') ? 'bg-indigo-600 text-white shadow-md' : 'bg-indigo-50 text-indigo-600 hover:bg-indigo-100'"
                                      class="px-4 py-1.5 rounded-full text-[11px] font-black uppercase tracking-tighter transition-all flex items-center gap-1.5 border border-indigo-100">
                                    <span class="w-1.5 h-1.5 bg-indigo-500 rounded-full animate-pulse"></span>
                                    MY VIBE
                                </Link>
                            </div>
                        </div>

                        <div class="hidden sm:ms-6 min-[835px]:flex sm:items-center">
                            <div class="relative ms-3">
                                <Dropdown v-if="$page.props.auth.user" align="right" width="48">
                                    <template #trigger>
                                        <span class="inline-flex rounded-md">
                                            <button type="button" class="inline-flex items-center rounded-md border border-transparent bg-white px-3 py-2 text-sm font-medium leading-4 text-gray-500 transition duration-150 ease-in-out hover:text-gray-700 focus:outline-none">
                                                {{ $page.props.auth.user.name }}
                                                <svg class="-me-0.5 ms-2 h-4 w-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                                                    <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
                                                </svg>
                                            </button>
                                        </span>
                                    </template>

                                    <template #content>
                                        <DropdownLink :href="route('profile.edit')"> Profile </DropdownLink>
                                        <DropdownLink :href="route('logout')" method="post" as="button"> Log Out </DropdownLink>
                                    </template>
                                </Dropdown>

                                <div v-else class="space-x-4">
                                    <Link :href="route('login')" class="text-sm font-bold text-gray-500 hover:text-gray-700">로그인</Link>
                                    <Link :href="route('register')" class="text-sm font-bold text-indigo-600 hover:text-indigo-800">회원가입</Link>
                                </div>
                            </div>
                        </div>

                        <div class="-me-2 flex items-center min-[835px]:hidden">
                            <button
                                @click="showingNavigationDropdown = !showingNavigationDropdown"
                                class="inline-flex items-center justify-center rounded-md p-2 text-gray-400 transition duration-150 ease-in-out hover:bg-gray-100 hover:text-gray-500 focus:bg-gray-100 focus:text-gray-500 focus:outline-none"
                            >
                                <svg class="h-6 w-6" stroke="currentColor" fill="none" viewBox="0 0 24 24">
                                    <path
                                        :class="{ hidden: showingNavigationDropdown, 'inline-flex': !showingNavigationDropdown }"
                                        stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"
                                    />
                                    <path
                                        :class="{ hidden: !showingNavigationDropdown, 'inline-flex': showingNavigationDropdown }"
                                        stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"
                                    />
                                </svg>
                            </button>
                        </div>
                    </div>
                </div>

                <div :class="{ block: showingNavigationDropdown, hidden: !showingNavigationDropdown }" class="min-[835px]:hidden">
                    <div class="space-y-1 pb-3 pt-2">
                        <ResponsiveNavLink :href="route('home')" :active="route().current('home')">홈</ResponsiveNavLink>
                        <ResponsiveNavLink :href="route('rankings')" :active="route().current('rankings')">순위</ResponsiveNavLink>
                        <ResponsiveNavLink :href="route('mixmatch')" :active="route().current('mixmatch')">믹스매치</ResponsiveNavLink>
                        <ResponsiveNavLink :href="route('posts.index')" :active="route().current('posts.*')">커뮤니티</ResponsiveNavLink>
                        <ResponsiveNavLink :href="route('trends')" :active="route().current('trends')">핫트렌드</ResponsiveNavLink>
                        <ResponsiveNavLink :href="route('remixes.index')" :active="route().current('remixes.index')">리믹스</ResponsiveNavLink>
                        <ResponsiveNavLink :href="route('favorites.index')" :active="route().current('favorites.index')">MY VIBE</ResponsiveNavLink>
                    </div>

                    <div class="border-t border-gray-200 pb-1 pt-4">
                        <template v-if="$page.props.auth.user">
                            <div class="px-4">
                                <div class="text-base font-medium text-gray-800">{{ $page.props.auth.user.name }}</div>
                                <div class="text-sm font-medium text-gray-500">{{ $page.props.auth.user.email }}</div>
                            </div>
                            <div class="mt-3 space-y-1">
                                <ResponsiveNavLink :href="route('profile.edit')"> Profile </ResponsiveNavLink>
                                <ResponsiveNavLink :href="route('logout')" method="post" as="button"> Log Out </ResponsiveNavLink>
                            </div>
                        </template>
                        <template v-else>
                            <div class="space-y-1">
                                <ResponsiveNavLink :href="route('login')"> 로그인 </ResponsiveNavLink>
                                <ResponsiveNavLink :href="route('register')"> 회원가입 </ResponsiveNavLink>
                            </div>
                        </template>
                    </div>
                </div>
            </nav>

            <header class="bg-white shadow" v-if="$slots.header">
                <div class="mx-auto max-w-7xl px-4 py-6 sm:px-6 lg:px-8">
                    <slot name="header" />
                </div>
            </header>

            <main>
                <slot />
            </main>

            <button 
                @click="isContactModalOpen = true"
                class="fixed bottom-8 right-8 w-14 h-14 bg-indigo-600 text-white rounded-full shadow-2xl hover:bg-indigo-700 transition-all flex items-center justify-center z-[60] hover:scale-110 active:scale-95 group"
            >
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 group-hover:rotate-12 transition-transform" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                </svg>
            </button>

            <div v-if="isContactModalOpen" 
                 class="fixed inset-0 z-[70] flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm"
                 @click.self="isContactModalOpen = false"
            >
                <div class="bg-white rounded-3xl p-8 w-full max-w-md shadow-2xl transform transition-all border border-gray-100">
                    <div class="flex justify-between items-center mb-6">
                        <h3 class="text-2xl font-black text-gray-900 tracking-tighter">
                            trend<span class="text-indigo-600">Vibe</span> 피드백
                        </h3>
                        <button @click="isContactModalOpen = false" class="text-gray-400 hover:text-gray-600 transition-colors">
                            <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                            </svg>
                        </button>
                    </div>
                    
                    <form @submit.prevent="submitContact" class="space-y-5">
                        <div>
                            <label class="block text-[10px] font-black uppercase tracking-[0.2em] text-gray-400 mb-1.5 ml-1">회신받을 이메일</label>
                            <input 
                                v-model="contactForm.email"
                                type="email" 
                                required
                                class="w-full border-gray-100 bg-gray-50 rounded-2xl focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-all py-3 px-4 text-sm"
                                placeholder="name@example.com"
                            />
                        </div>

                        <div>
                            <label class="block text-[10px] font-black uppercase tracking-[0.2em] text-gray-400 mb-1.5 ml-1">문의 및 제안</label>
                            <textarea 
                                v-model="contactForm.message"
                                required
                                rows="4"
                                class="w-full border-gray-100 bg-gray-50 rounded-2xl focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-all py-3 px-4 text-sm resize-none"
                                placeholder="TrendVibe를 더 즐겁게 만들 아이디어를 들려주세요!"
                            ></textarea>
                        </div>

                        <button 
                            type="submit"
                            :disabled="contactForm.processing"
                            class="w-full py-4 bg-indigo-600 text-white rounded-2xl font-black text-[11px] uppercase tracking-[0.2em] hover:bg-indigo-700 disabled:opacity-50 transition-all shadow-xl shadow-indigo-100 mt-2"
                        >
                            {{ contactForm.processing ? '보내는 중...' : '메시지 전송하기' }}
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</template>