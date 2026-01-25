<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class Cors
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $response = $next($request);

        // Vue.js 개발 서버 주소 허용
        $response->headers->set('Access-Control-Allow-Origin', 'http://localhost:5173');
        $response->headers->set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
        $response->headers->set('Access-Control-Allow-Headers', 'Content-Type, X-Requested-With, Origin, Accept');
        $response->headers->set('Access-Control-Allow-Credentials', 'true');

        // OPTIONS 요청에 대한 사전 응답 (필수)
        if ($request->isMethod('OPTIONS')) {
            return $response;
        }

        return $response;
    }
}
