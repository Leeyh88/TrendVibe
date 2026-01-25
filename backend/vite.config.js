import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
    plugins: [
        laravel({
            input: 'resources/js/app.js',
            refresh: true,
        }),
        vue({
            template: {
                transformAssetUrls: {
                    base: null,
                    includeAbsolute: false,
                },
            },
        }),
    ],
    server: {
        host: '0.0.0.0', // 컨테이너 외부(브라우저)에서 접속 허용
        port: 5173,
        strictPort: true, // 5173 포트가 점유 중이면 에러를 내서 충돌 방지
        hmr: {
            host: 'localhost', // 브라우저가 핫 리로딩을 위해 접속할 주소
        },
    },
});