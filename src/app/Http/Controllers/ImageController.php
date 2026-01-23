<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ImageController extends Controller
{
    public function store(Request $request)
    {
        // 1. 이미지 유효성 검사
        $request->validate([
            'image' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048'
        ]);

        if ($request->hasFile('image')) {
            // 2. 'public/uploads' 폴더에 저장
            $path = $request->file('image')->store('uploads', 'public');
            
            // 3. 저장된 이미지의 풀 URL 생성 (예: http://localhost/storage/uploads/abc.jpg)
            $url = asset('storage/' . $path);

            return response()->json(['url' => $url]);
        }

        return response()->json(['error' => '이미지 업로드 실패'], 400);
    }
}