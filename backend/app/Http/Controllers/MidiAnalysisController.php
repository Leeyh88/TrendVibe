<?php

namespace App\Http\Controllers;

// 1. 서비스 클래스를 반드시 상단에 use 해야 합니다.
use App\Services\MidiAnalysisService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Process;
use Illuminate\Support\Facades\Http;
use Inertia\Inertia;

class MidiAnalysisController extends Controller
{
    // 2. 생성자에서 서비스를 주입받습니다.
    public function __construct(
        protected MidiAnalysisService $midiService
    ) {}

    public function index()
    {
        return Inertia::render('Midi/Analysis');
    }

    public function analyze(Request $request)
    {
        $request->validate(['midi_file' => 'required|file']);

        // 1. 파일 저장
        $path = $request->file('midi_file')->store('temp_midi', 'local');
        $fullPath = \Illuminate\Support\Facades\Storage::disk('local')->path($path);

        // 2. 디버깅: 파일이 정말 있는지 PHP 수준에서 먼저 확인
        if (!file_exists($fullPath)) {
            return response()->json([
                'status' => 'error',
                'message' => 'PHP가 파일을 찾지 못했습니다: ' . $fullPath
            ], 500);
        }

        // 3. 서비스 호출
        $result = $this->midiService->analyze($fullPath);

        return response()->json($result);
    }
}