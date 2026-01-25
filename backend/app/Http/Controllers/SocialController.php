<?php

namespace App\Http\Controllers;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Laravel\Socialite\Facades\Socialite;
use Exception;

class SocialController extends Controller
{
    // 카카오 로그인 화면으로 이동
    public function redirectToKakao()
    {
        return Socialite::driver('kakao')->redirect();
    }

    // 카카오 콜백 처리
    public function handleKakaoCallback()
    {
        try {
            $kakaoUser = Socialite::driver('kakao')->user();
            // dd($kakaoUser);
            
            $user = User::updateOrCreate([
                'email' => $kakaoUser->email,
            ], [
                'name' => $kakaoUser->name,
                'kakao_id' => $kakaoUser->id,
                'password' => null,
            ]);

            Auth::login($user);
            return redirect()->to('/');
        } catch (\Exception $e) {
            return redirect('/login')->with('error', '카카오 로그인 실패');
        }
    }
}
