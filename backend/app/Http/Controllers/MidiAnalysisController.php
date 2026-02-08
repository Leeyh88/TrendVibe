<?php

namespace App\Http\Controllers;

use App\Services\MidiAnalysisService;
use Illuminate\Http\Request;
use App\Models\Analysis;
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

    public function list()
    {
        $list = \App\Models\Analysis::where('user_id', auth()->id())
                ->orderBy('created_at', 'desc')
                ->get()
                ->map(function ($item) {
                    return [
                        'id' => $item->id,
                        'status' => $item->status,
                        'created_at' => $item->created_at->format('Y-m-d H:i'),
                        // file_path가 이미 'midi_uploads/xxx.mid' 형태라고 가정
                        'file_url' => $item->file_path ? asset('storage/' . $item->file_path) : null,
                        'bpm' => $item->bpm,
                    ];
                });

        // resources/js/Pages/Midi/List.vue (또는 본인의 경로)로 데이터 전달
        return Inertia::render('Midi/List', [
            'midiList' => $list
        ]);
    }

    public function analyze(Request $request)
    {
        $request->validate(['midi_file' => 'required|file']);
        $path = $request->file('midi_file')->store('midi_uploads', 'public'); 
        $fullPath = storage_path('app/public/' . $path); 

        $analysis = \App\Models\Analysis::create([
            'user_id' => auth()->id(),
            'status' => 'pending',
            'file_path' => $path, // 'midi_uploads/파일명.mid' 형태로 저장됨
        ]);

        \App\Jobs\AnalyzeMidiJob::dispatch($fullPath, $analysis->id);

        return response()->json([
            'id' => $analysis->id,
            'status' => 'pending'
        ]);
    }

    public function show(Analysis $analysis)
    {
        if ($analysis->user_id !== auth()->id()) abort(403);

        return Inertia::render('Midi/Show', [
            'analysis' => $analysis
        ]);
    }
}