<script setup>
import { ref } from 'vue';
import axios from 'axios';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';

const file = ref(null);
const result = ref(null);
const loading = ref(false);

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
        result.value = response.data;
    } catch (error) {
        console.error("분석 실패:", error);
    } finally {
        loading.value = false;
    }
};
</script>

<template>
    <AuthenticatedLayout>
        <div class="py-12 max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg p-6">
                <h2 class="text-xl font-bold mb-4">AI MIDI 분석 (Qwen)</h2>
                
                <input type="file" @change="handleFileUpload" accept=".mid,.midi" class="mb-4 block" />
                
                <button 
                    @click="submitAnalysis" 
                    :disabled="loading"
                    class="bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700 disabled:opacity-50"
                >
                    {{ loading ? '분석 중...' : '분석 시작' }}
                </button>

                <div v-if="result" class="mt-6 p-4 bg-gray-50 rounded-lg border">
                    <h3 class="font-bold text-gray-700 mb-2">분석 결과</h3>
                    <pre class="text-sm overflow-x-auto">{{ JSON.stringify(result, null, 2) }}</pre>
                </div>
            </div>
        </div>
    </AuthenticatedLayout>
</template>