<?php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use App\Services\MidiAnalysisService;
use App\Models\Analysis;
use Illuminate\Support\Facades\Log;

class AnalyzeMidiJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $filePath;
    protected $analysisId;
    
    public function __construct($filePath, $analysisId)
    {
        $this->filePath = $filePath;
        $this->analysisId = $analysisId;
    }

    public function handle(MidiAnalysisService $service)
    {
        Log::info("MIDI 분석 작업 시작 - ID: {$this->analysisId}");

        $analysis = Analysis::find($this->analysisId);
        if (!$analysis) {
            Log::error("Analysis 모델을 찾을 수 없음 - ID: {$this->analysisId}");
            return;
        }
    
        $analysis->update(['status' => 'processing']);

        try {
            $result = $service->analyze($this->filePath);

            $analysis->update([
                'status'          => 'completed',
                'bpm'             => $result['bpm'] ?? null,
                'tracks'          => $result['tracks'] ?? null,
                'duration'        => $result['duration'] ?? null,
                'harmony_scores'  => $result['harmony_scores'] ?? null,
                'timeline_labels' => $result['timeline_labels'] ?? null,
                'ai_comment'      => $result['ai_comment'] ?? null,
            ]);

            if (file_exists($this->filePath)) {
                unlink($this->filePath);
            }
            Log::info("MIDI 분석 작업 완료 - ID: {$this->analysisId}");

        } catch (\Exception $e) {
            Log::error("MIDI 분석 실패: " . $e->getMessage());
            $analysis->update(['status' => 'failed']);
        }
    }
}