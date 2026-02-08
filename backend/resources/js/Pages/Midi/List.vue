<script setup>
import { Link, Head } from '@inertiajs/vue3'; 
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue'; 

const props = defineProps({
    midiList: Array
});

// 상태별 스타일 정의 (더 강렬한 배지 스타일)
const getStatusClass = (status) => {
    const base = 'px-2 py-0.5 rounded text-[10px] font-black uppercase tracking-tighter shadow-sm';
    const styles = {
        completed: 'bg-green-500 text-white',
        processing: 'bg-indigo-600 text-white animate-pulse',
        pending: 'bg-yellow-400 text-black',
        failed: 'bg-red-500 text-white'
    };
    return `${base} ${styles[status] || styles.pending}`;
};
</script>

<template>
    <Head title="MIDI Archive" />
    <AuthenticatedLayout>
        <div class="py-12 bg-[#F8FAFC] min-h-screen">
            <div class="max-w-6xl mx-auto px-6">
                <header class="mb-10 flex flex-col md:flex-row md:items-end justify-between gap-6">
                    <div>
                        <div class="flex items-center gap-2 mb-2">
                            <span class="px-2 py-0.5 bg-indigo-600 text-white text-[10px] font-black rounded uppercase">Database</span>
                        </div>
                        <h1 class="text-4xl font-black text-gray-900 tracking-tighter uppercase italic">Midi Archive</h1>
                        <p class="text-gray-400 font-bold mt-1 uppercase tracking-widest text-[10px]">Review your previous AI inspections.</p>
                    </div>

                    <Link :href="route('midi.index')" class="inline-flex items-center px-6 py-3 bg-gray-900 text-white rounded-2xl font-black text-sm shadow-xl shadow-gray-200 hover:bg-indigo-600 hover:-translate-y-1 transition-all uppercase tracking-tight">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M12 4v16m8-8H4" /></svg>
                        New Analysis
                    </Link>
                </header>

                <div class="grid gap-4">
                    <div v-for="item in midiList" :key="item.id" 
                         class="group bg-white overflow-hidden shadow-sm hover:shadow-xl sm:rounded-3xl p-6 border border-gray-100 flex flex-col md:flex-row items-center justify-between transition-all duration-300 hover:border-indigo-200">
                        
                        <div class="flex items-center gap-6 w-full md:w-auto">
                            <div class="hidden sm:flex w-14 h-14 bg-gray-50 rounded-2xl items-center justify-center text-gray-300 group-hover:bg-indigo-50 group-hover:text-indigo-600 transition-colors">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-7 w-7" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3" />
                                </svg>
                            </div>
                            <div class="flex flex-col">
                                <div class="flex items-center gap-3 mb-1">
                                    <span class="text-[10px] font-black text-indigo-500 uppercase tracking-widest">ID #{{ item.id }}</span>
                                    <span :class="getStatusClass(item.status)">{{ item.status }}</span>
                                </div>
                                <h3 class="text-xl font-black text-gray-900 italic uppercase tracking-tighter">MIDI Project Analysis</h3>
                                <p class="text-xs text-gray-400 font-bold uppercase">{{ item.created_at }}</p>
                            </div>
                        </div>

                        <div class="flex items-center gap-4 mt-6 md:mt-0 w-full md:w-auto justify-end">
                            <div v-if="item.bpm" class="hidden lg:flex flex-col items-end mr-4">
                                <span class="text-[8px] font-black text-gray-300 uppercase">Tempo</span>
                                <span class="text-lg font-black text-gray-700 italic tracking-tighter">{{ item.bpm }} BPM</span>
                            </div>

                            <Link :href="route('midi.show', item.id)" 
                                  class="px-8 py-3 bg-gray-100 text-gray-900 rounded-2xl font-black text-xs uppercase tracking-widest hover:bg-indigo-600 hover:text-white transition-all shadow-sm">
                                View Report
                            </Link>

                            <a v-if="item.file_url" :href="item.file_url" target="_blank" 
                               class="p-3 text-gray-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-2xl transition-all" title="Download">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                                </svg>
                            </a>
                        </div>
                    </div>

                    <div v-if="midiList.length === 0" class="text-center py-24 bg-white rounded-3xl border border-dashed border-gray-200">
                        <p class="text-gray-400 font-black uppercase tracking-widest text-sm italic">No Analysis History Found.</p>
                        <Link :href="route('midi.index')" class="text-indigo-600 font-bold text-xs mt-2 inline-block hover:underline uppercase">Start your first analysis now</Link>
                    </div>
                </div>
            </div>
        </div>
    </AuthenticatedLayout>
</template>