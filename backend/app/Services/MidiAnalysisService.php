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
        $scoreDetails = "";
        foreach ($data['timeline_labels'] as $index => $time) {
            $scoreDetails .= "{$time}초: {$data['harmony_scores'][$index]}점, ";
        }

        $prompt = "당신은 전문 음악 프로듀서이자 MIDI 분석 전문가입니다. 아래 데이터를 바탕으로 곡의 [잘한 점]과 [아쉬운 점]을 기술적으로 분석하세요.\n\n"
                    . "### MIDI 데이터\n"
                    . "- BPM: {$data['bpm']}\n"
                    . "- 트랙 수: {$data['tracks']}\n"
                    . "- 총 재생 시간: {$data['duration']}초\n"
                    . "- 시간별 화성 일치도: {$scoreDetails}\n\n"
                    . "### 요청 사항\n"
                    . "1. [잘한 점]: 곡의 전반적인 분위기와 구성의 장점을 설명하세요.\n"
                    . "2. [아쉬운 점]: 화성 일치도 점수가 60점 미만으로 떨어진 구간을 구체적으로 언급하며, 왜 음악적으로 불안정할 수 있는지(예: 불협화음 가능성) 지적하세요.\n"
                    . "3. [개선 방향]: 더 나은 리믹스를 위해 어떤 작업을 해야 할지 제안하세요.\n"
                    . "4. 모든 답변은 한국어로, 전문가답지만 간결하게 작성하세요.";

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