<?php

namespace App\Services;

use Illuminate\Support\Facades\Process;
use Illuminate\Support\Facades\Http;

class MidiAnalysisService
{
// app/Services/MidiAnalysisService.php

    public function analyze($filePath)
    {
        $result = Process::run([
            'python3',
            base_path('scripts/analyze_midi.py'),
            $filePath
        ]);

        // 1. 파이썬 실행 결과 파싱
        $midiData = json_decode($result->output(), true);

        // 2. 파이썬 내부에서 파일 못 찾음 등의 에러를 뱉은 경우 처리
        if (isset($midiData['status']) && $midiData['status'] === 'error') {
            return [
                'status' => 'error',
                'message' => '분석기 오류: ' . ($midiData['message'] ?? '알 수 없는 오류')
            ];
        }

        // 3. 실행 자체가 실패했거나 결과가 비어있는 경우
        if (!$result->successful() || empty($midiData)) {
            return [
                'status' => 'error',
                'message' => '파이썬 실행 실패: ' . $result->errorOutput()
            ];
        }

        // 4. 성공 시 AI 분석 단계로 이동
        return $this->askAiForAnalysis($midiData);
    }
    protected function askAiForAnalysis($data)
    {
        $prompt = "다음 MIDI 파일 분석 데이터를 바탕으로 이 곡의 장르, 분위기, 그리고 추천 활용도를 한국어로 짧게 분석해줘.\n"
                . "데이터: BPM {$data['bpm']}, 트랙 수 {$data['tracks']}, 재생 시간 {$data['duration']}초";

        try {
            $response = Http::timeout(30)->post('http://host.docker.internal:11434/api/generate', [
                'model' => 'gemma2:2b', 
                'prompt' => $prompt,
                'stream' => false
            ]);

            $aiAnalysis = $response->json()['response'] ?? 'AI 분석 결과를 가져올 수 없습니다.';

            return array_merge($data, [
                'status' => 'success',
                'ai_comment' => $aiAnalysis
            ]);
        } catch (\Exception $e) {
            return array_merge($data, [
                'status' => 'partial_success',
                'ai_comment' => 'AI 연결 실패: ' . $e->getMessage()
            ]);
        }
    }
}