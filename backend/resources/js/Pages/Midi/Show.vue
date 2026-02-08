<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';
import { Link, Head } from '@inertiajs/vue3';
import axios from 'axios';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Line } from 'vue-chartjs';

// ChartJS 모듈 등록
import { 
    Chart as ChartJS, Title, Tooltip, Legend, LineElement, PointElement, CategoryScale, LinearScale, Filler 
} from 'chart.js';

ChartJS.register(Title, Tooltip, Legend, LineElement, PointElement, CategoryScale, LinearScale, Filler);

const props = defineProps(['analysis']);

const result = ref(props.analysis);
const loading = ref(result.value.status !== 'completed');
let timer = null;

const formatTime = (seconds) => {
    const min = Math.floor(seconds / 60);
    const sec = Math.floor(seconds % 60);
    return `${min.toString().padStart(2, '0')}:${sec.toString().padStart(2, '0')}`;
};

const chartData = computed(() => {
    const scores = result.value?.harmony_scores;
    const timeline = result.value?.timeline_labels;
    if (!scores || !timeline) return { labels: [], datasets: [] };
    return {
        labels: timeline.map(time => formatTime(time)),
        datasets: [{
            label: '화성 일치도 (%)',
            data: scores,
            borderColor: '#4F46E5',
            backgroundColor: 'rgba(79, 70, 229, 0.1)',
            fill: true,
            tension: 0.4,
            pointBackgroundColor: scores.map(s => s < 60 ? '#EF4444' : '#4F46E5'),
            pointRadius: 5
        }]
    };
});

const chartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    scales: {
        y: { min: 0, max: 100, title: { display: true, text: 'Score', font: { weight: 'bold' } } },
        x: { title: { display: true, text: 'Time (mm:ss)', font: { weight: 'bold' } } }
    },
    plugins: {
        tooltip: {
            callbacks: { label: (context) => `일치도: ${context.parsed.y}%` }
        }
    }
};

const formattedAiComment = computed(() => {
    if (!result.value?.ai_comment) return '';
    let text = String(result.value.ai_comment).trim();
    text = text.replace(/^##\s*(.*)$/gm, '<h2 class="text-2xl font-black text-indigo-900 border-b-4 border-indigo-500 pb-2 mb-8 tracking-tight">$1</h2>');
    const keywords = ['잘한 점', '아쉬운 점', '개선 방향', '추가 제안', '결론'];
    keywords.forEach(key => {
        const regex = new RegExp(`^(\\s*|\\*\\*|\\d+\\.\\s*)${key}(.*)$`, 'gm');
        text = text.replace(regex, `<h3 class="flex items-center gap-2 text-xl font-bold text-gray-800 mt-10 mb-4"><span class="w-2 h-6 bg-indigo-500 rounded-full"></span>${key}$2</h3>`);
    });
    text = text.replace(/\*\*(.*?)\*\*/g, '<strong class="text-indigo-600 font-extrabold bg-indigo-50 px-1.5 py-0.5 rounded">$1</strong>');
    return text.split('\n').join('<br>');
});

const fetchStatus = async () => {
    try {
        const res = await axios.get(`/api/midi-analyze/${result.value.id}`);
        result.value = res.data;
        if (result.value.status === 'completed') {
            loading.value = false;
            clearInterval(timer);
        }
    } catch (e) {
        clearInterval(timer);
    }
};

onMounted(() => {
    if (loading.value) timer = setInterval(fetchStatus, 3000);
});

onUnmounted(() => { if (timer) clearInterval(timer); });
</script>

<template>
    <Head title="Analysis Report" />
    <AuthenticatedLayout>
        <div class="py-12 bg-[#F8FAFC] min-h-screen">
            <div class="max-w-5xl mx-auto px-6">
                <header class="mb-10 flex flex-col md:flex-row md:items-end justify-between gap-6">
                    <div>
                        <div class="flex items-center gap-2 mb-2">
                            <span class="px-2 py-0.5 bg-indigo-600 text-white text-[10px] font-black rounded uppercase">Deep Analysis</span>
                        </div>
                        <h1 class="text-4xl font-black text-gray-900 tracking-tighter uppercase italic">Midi AI Report</h1>
                        <p class="text-gray-400 font-bold mt-1 uppercase tracking-widest text-[10px]">Precision Inspection of your music data.</p>
                    </div>

                    <Link :href="route('midi.list')" class="inline-flex items-center px-6 py-3 bg-gray-900 text-white rounded-2xl font-black text-sm shadow-xl shadow-gray-200 hover:bg-indigo-600 hover:-translate-y-1 transition-all uppercase tracking-tight">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M4 6h16M4 12h16M4 18h7" />
                        </svg>
                        Back to List
                    </Link>
                </header>

                <div class="bg-white overflow-hidden shadow-xl sm:rounded-3xl p-8 border border-gray-100">
                    
                    <div class="flex items-center justify-between mb-8 pb-6 border-b border-gray-50">
                        <div class="flex items-center gap-3">
                            <div class="w-3 h-3 rounded-full" :class="loading ? 'bg-yellow-400 animate-pulse' : 'bg-green-500'"></div>
                            <span class="text-sm font-black text-gray-700 uppercase tracking-widest">
                                Report ID: #{{ result.id }}
                            </span>
                        </div>
                        <span v-if="!loading" class="px-3 py-1 bg-green-100 text-green-700 rounded-full text-[10px] font-black uppercase tracking-tighter">
                            Analysis Complete
                        </span>
                    </div>

                    <div v-if="loading" class="py-20 text-center">
                        <div class="animate-spin rounded-full h-16 w-16 border-b-4 border-indigo-600 mx-auto"></div>
                        <p class="mt-6 text-xl font-black text-gray-900 tracking-tighter uppercase italic">AI Processing...</p>
                        <p class="text-gray-400 font-bold mt-2">화성학 데이터 분석 및 코멘터리를 생성 중입니다.</p>
                    </div>

                    <div v-else class="space-y-12 animate-in fade-in slide-in-from-bottom-4 duration-1000">
                        
                        <div class="bg-gray-50/50 p-6 rounded-3xl border border-gray-100 shadow-sm">
                            <div class="flex items-center justify-between mb-6">
                                <h4 class="text-lg font-black text-gray-900 flex items-center gap-2 uppercase italic tracking-tighter">
                                    <span class="p-1.5 bg-indigo-600 rounded-lg text-white shadow-lg shadow-indigo-100">
                                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M7 12l3-3 3 3 4-4" /></svg>
                                    </span>
                                    Harmony Diagnostic
                                </h4>
                                <div class="text-[10px] font-black text-gray-400 uppercase tracking-widest">Score over time</div>
                            </div>
                            <div style="height: 350px;">
                                <Line v-if="result.harmony_scores" :data="chartData" :options="chartOptions" />
                            </div>
                        </div>

                        <div class="space-y-6">
                            <div class="flex items-center gap-4">
                                <h3 class="text-2xl font-black text-gray-900 uppercase italic tracking-tighter">AI Commentary</h3>
                                <div class="h-1 flex-1 bg-gray-100 rounded-full"></div>
                            </div>
                            
                            <div v-if="result.ai_comment" 
                                class="prose prose-indigo max-w-none text-gray-700 leading-relaxed custom-ai-report bg-white p-8 rounded-3xl border border-gray-100 shadow-sm">
                                <div v-html="formattedAiComment"></div>
                            </div>
                        </div>

                        <div class="grid grid-cols-3 gap-6 border-t border-gray-50 pt-10">
                            <div class="p-6 bg-white border border-gray-100 rounded-3xl shadow-sm hover:border-indigo-200 transition-colors">
                                <p class="text-[10px] font-black text-indigo-500 mb-2 uppercase tracking-widest">Tempo</p>
                                <p class="text-2xl font-black text-gray-900 italic tracking-tighter">{{ result.bpm }} <span class="text-sm font-bold text-gray-400 uppercase">BPM</span></p>
                            </div>
                            <div class="p-6 bg-white border border-gray-100 rounded-3xl shadow-sm hover:border-indigo-200 transition-colors">
                                <p class="text-[10px] font-black text-indigo-500 mb-2 uppercase tracking-widest">Tracks</p>
                                <p class="text-2xl font-black text-gray-900 italic tracking-tighter">{{ result.tracks }} <span class="text-sm font-bold text-gray-400 uppercase">Ch.</span></p>
                            </div>
                            <div class="p-6 bg-white border border-gray-100 rounded-3xl shadow-sm hover:border-indigo-200 transition-colors">
                                <p class="text-[10px] font-black text-indigo-500 mb-2 uppercase tracking-widest">Duration</p>
                                <p class="text-2xl font-black text-gray-900 italic tracking-tighter">{{ formatTime(result.duration) }}</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </AuthenticatedLayout>
</template>

<style scoped>
.custom-ai-report :deep(strong) {
    color: #4f46e5;
    font-weight: 900;
    background: linear-gradient(120deg, rgba(79, 70, 229, 0.1) 0%, rgba(79, 70, 229, 0.05) 100%);
    padding: 2px 6px;
    border-radius: 6px;
}
.custom-ai-report :deep(h2) { font-size: 1.5rem; margin-top: 3rem; }
.custom-ai-report :deep(p) { margin-bottom: 1.5rem; font-size: 1.05rem; }
</style>