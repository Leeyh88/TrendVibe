<?php

namespace App\Http\Controllers;

use App\Models\Contact;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class ContactController extends Controller
{
    public function store(Request $request)
    {
        // 1. 유효성 검사
        $validated = $request->validate([
            'email' => 'required|email|max:255',
            'message' => 'required|string|min:5|max:2000',
        ]);

        try {
            // 2. DB 저장
            Contact::create([
                'email' => $validated['email'],
                'message' => $validated['message'],
                'is_read' => false,
            ]);

            // [참고] 내일 AWS SES 연동 후 여기에 메일 발송 로직을 추가할 예정입니다.
            // Mail::to('admin@trendvibe.net')->send(new NewContactNotification($validated));

            // 3. 성공 응답 (Inertia는 이전 페이지로 리다이렉트)
            return back()->with('success', '메시지가 성공적으로 전달되었습니다.');

        } catch (\Exception $e) {
            // 에러 발생 시 로그 기록
            Log::error("Contact Save Error: " . $e->getMessage());
            
            return back()->withErrors(['message' => '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.']);
        }
    }
}