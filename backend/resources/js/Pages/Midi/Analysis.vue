<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';
import axios from 'axios';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Line } from 'vue-chartjs';
import { router, Link, Head } from '@inertiajs/vue3';

// ChartJS 모듈 등록
import { 
    Chart as ChartJS, Title, Tooltip, Legend, LineElement, PointElement, CategoryScale, LinearScale, Filler 
} from 'chart.js';

ChartJS.register(Title, Tooltip, Legend, LineElement, PointElement, CategoryScale, LinearScale, Filler);

const props = defineProps(['analysis']);

// --- 상태 관리 ---
const result = ref(props.analysis || null); // 처음 진입 시 데이터가 없을 수 있음
const file = ref(null);
const loading = ref(false);
let timer = null;

// --- 업로드 로직 ---
const handleFileUpload = (e) => {
    file.value = e.target.files[0];
};

const submitAnalysis = async () => {
    if (!file.value) return;
    
    loading.value = true;
    const formData = new FormData();
    formData.append('midi_file', file.value);

    try {
        const response = await axios.post('/api/midi-analyze', formData);
        const analysisId = response.data.id;
        
        // --- 3초 리미트 로직 시작 ---
        let passedTime = 0;
        const limit = 3000; // 3초
        const intervalTime = 1000; // 1초마다 체크

        const timer = setInterval(async () => {
            passedTime += intervalTime;

            // 상태 체크 API 호출
            const statusRes = await axios.get(`/midi-analyze/${analysisId}`);
            
            if (statusRes.data.status === 'completed') {
                // 1. 3초 안에 완료된 경우: 그 자리에서 결과 바인딩
                clearInterval(timer);
                result.value = statusRes.data; 
                loading.value = false;
            } else if (passedTime >= limit) {
                // 2. 3초가 지난 경우: 목록 페이지로 이동
                clearInterval(timer);
                alert('분석이 길어지고 있습니다. 목록에서 결과를 확인해주세요.');
                router.visit('/midi-analyze/list'); // 목록 페이지 경로
            }
        }, intervalTime);
    } catch (error) {
        console.error("요청 실패:", error);
        loading.value = false;
    }
};

const formatTime = (seconds) => {
    const min = Math.floor(seconds / 60);
    const sec = Math.floor(seconds % 60);
    return `${min.toString().padStart(2, '0')}:${sec.toString().padStart(2, '0')}`;
};

// --- 차트 및 리포트 계산 로직 (기존과 동일) ---
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
        y: { min: 0, max: 100 },
        x: { title: { display: true, text: 'Time (mm:ss)' } }
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

onMounted(() => {
    // 만약 리스트에서 'pending' 상태인 데이터를 클릭해서 들어온 경우를 위해
    if (result.value && result.value.status !== 'completed') {
        loading.value = true;
        startPolling(result.value.id);
    }
});

onUnmounted(() => { if (timer) clearInterval(timer); });
</script>

<template>
    <Head title="MIDI Analysis" />
    <AuthenticatedLayout>
        <div class="py-12 bg-[#F8FAFC] min-h-screen">
            <div class="max-w-5xl mx-auto px-6">
                <header class="mb-10 flex flex-col md:flex-row md:items-end justify-between gap-6">
                    <div>
                        <div class="flex items-center gap-2 mb-2">
                            <span class="px-2 py-0.5 bg-indigo-600 text-white text-[10px] font-black rounded uppercase">Deep Analysis</span>
                        </div>
                        <h1 class="text-4xl font-black text-gray-900 tracking-tighter uppercase italic">Midi AI Report</h1>
                        <p class="text-gray-400 font-bold mt-1 uppercase tracking-widest text-[10px]">Upload or View your MIDI insights.</p>
                    </div>
                    <Link :href="route('midi.list')" class="inline-flex items-center px-6 py-3 bg-gray-900 text-white rounded-2xl font-black text-sm shadow-xl shadow-gray-200 hover:bg-indigo-600 hover:-translate-y-1 transition-all uppercase tracking-tight">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M4 6h16M4 12h16M4 18h7" />
                        </svg>
                        List
                    </Link>
                </header>

                <div class="bg-white overflow-hidden shadow-xl sm:rounded-3xl p-8 border border-gray-100">
                    
                    <div v-if="!result && !loading" class="py-10">
                        <div class="text-center mb-10">
                            <div class="w-20 h-20 bg-indigo-50 rounded-3xl flex items-center justify-center mx-auto mb-4">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10 text-indigo-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3" />
                                </svg>
                            </div>
                            <h2 class="text-2xl font-black text-gray-900 tracking-tight">새로운 미디 분석 시작</h2>
                            <p class="text-gray-600 font-medium">AI가 당신의 연주를 화성학적으로 정밀 진단합니다.</p>
                            <p class="text-gray-400 font-medium">MIDI파일을 업로드 후 분석 을 해주세요.</p>
                        </div>
                        
                        <div class="flex items-center gap-4 p-6 bg-indigo-50/50 rounded-3xl border-2 border-dashed border-indigo-200">
                            <input type="file" @change="handleFileUpload" accept=".mid,.midi" 
                                class="block w-full text-sm text-gray-500 file:mr-4 file:py-2.5 file:px-6 file:rounded-2xl file:border-0 file:text-sm file:font-black file:bg-indigo-600 file:text-white hover:file:bg-indigo-700 cursor-pointer" />
                            <button @click="submitAnalysis" :disabled="!file"
                                class="shrink-0 bg-gray-900 text-white px-8 py-3 rounded-2xl font-black hover:bg-indigo-600 transition-all disabled:opacity-30 shadow-xl">
                                분석 시작
                            </button>
                        </div>
                    </div>

                    <div v-else-if="loading" class="py-24 text-center">
                        <div class="animate-spin rounded-full h-16 w-16 border-b-4 border-indigo-600 mx-auto"></div>
                        <p class="mt-6 text-xl font-black text-gray-900 tracking-tighter uppercase italic">AI Processing...</p>
                        <p class="text-gray-400 font-bold mt-2">화성학 데이터 분석 및 AI 코멘터리를 생성 중입니다.</p>
                    </div>

                    <div v-else-if="result" class="space-y-12 animate-in fade-in slide-in-from-bottom-4 duration-1000">
                        <div class="bg-gray-50/50 p-6 rounded-3xl border border-gray-100 shadow-sm">
                            <h4 class="text-lg font-black text-gray-900 flex items-center gap-2 uppercase italic tracking-tighter mb-6">
                                <span class="p-1.5 bg-indigo-600 rounded-lg text-white shadow-lg shadow-indigo-100">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M7 12l3-3 3 3 4-4" /></svg>
                                </span>
                                Harmony Diagnostic
                            </h4>
                            <div style="height: 320px;">
                                <Line :data="chartData" :options="chartOptions" />
                            </div>
                        </div>

                        <div class="space-y-6">
                            <div class="flex items-center gap-4">
                                <h3 class="text-2xl font-black text-gray-900 uppercase italic tracking-tighter">AI Commentary</h3>
                                <div class="h-1 flex-1 bg-gray-100 rounded-full"></div>
                            </div>
                            <div class="prose prose-indigo max-w-none text-gray-700 leading-relaxed custom-ai-report bg-white p-8 rounded-3xl border border-gray-100 shadow-sm">
                                <div v-html="formattedAiComment"></div>
                            </div>
                        </div>

                        <div class="grid grid-cols-3 gap-6 border-t border-gray-50 pt-10 text-center">
                            <div class="p-6 bg-white border border-gray-100 rounded-3xl shadow-sm">
                                <p class="text-[10px] font-black text-indigo-500 mb-2 uppercase">Tempo</p>
                                <p class="text-2xl font-black text-gray-900 italic tracking-tighter">{{ result.bpm }} BPM</p>
                            </div>
                            <div class="p-6 bg-white border border-gray-100 rounded-3xl shadow-sm">
                                <p class="text-[10px] font-black text-indigo-500 mb-2 uppercase">Tracks</p>
                                <p class="text-2xl font-black text-gray-900 italic tracking-tighter">{{ result.tracks }} Ch.</p>
                            </div>
                            <div class="p-6 bg-white border border-gray-100 rounded-3xl shadow-sm">
                                <p class="text-[10px] font-black text-indigo-500 mb-2 uppercase">Duration</p>
                                <p class="text-2xl font-black text-gray-900 italic tracking-tighter">{{ formatTime(result.duration) }}</p>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </AuthenticatedLayout>
</template>