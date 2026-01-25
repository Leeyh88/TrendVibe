<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Laravel\Socialite\Facades\Socialite;
use Exception;

class GoogleController extends Controller
{
    /**
     * 구글 로그인 페이지로 리다이렉트
     */
    public function redirectToGoogle()
    {
        return Socialite::driver('google')->redirect();
    }

    /**
     * 구글로부터 콜백 처리
     */
    public function handleGoogleCallback()
    {
        try {
            $googleUser = Socialite::driver('google')->user();

            // 이메일로 기존 사용자를 찾거나 없으면 새로 생성
            $user = User::updateOrCreate([
                'email' => $googleUser->email,
            ], [
                'name' => $googleUser->name,
                'google_id' => $googleUser->id,
                'password' => null, // 소셜 사용자는 비밀번호가 필요 없음
            ]);

            Auth::login($user);

            // 성공 시 대시보드나 메인으로 이동
            return redirect()->intended('/');

        } catch (Exception $e) {
            // 에러 발생 시 로그인 페이지로 리다이렉트
            return redirect('/login')->with('error', '구글 로그인 중 오류가 발생했습니다.');
        }
    }
}