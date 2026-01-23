const puppeteer = require('puppeteer');
const mysql = require('mysql2/promise');

// DB 설정 (Docker 환경변수 참조)
const dbConfig = {
    host: process.env.DB_HOST || 'mariadb',
    user: process.env.DB_USER || 'tm_user',
    password: process.env.DB_PASS || 'tm_password',
    database: process.env.DB_NAME || 'tm_db',
};

/**
 * 1. SoundCloud 크롤링 로직
 */
async function crawlSoundCloud(page) {
    console.log('SoundCloud: 데이터 수집 중');
    await page.goto('https://soundcloud.com/discover', { waitUntil: 'networkidle2', timeout: 60000 });
    
    return await page.evaluate(() => {
        const items = document.querySelectorAll('.v2-dash-track-item'); 
        return Array.from(items).slice(0, 10).map(el => ({
            title: el.querySelector('.title')?.innerText?.trim() || 'Unknown Title',
            artist: el.querySelector('.artist')?.innerText?.trim() || 'Unknown Artist',
            platform: 'SoundCloud'
        }));
    });
}

/**
 * 2. Spotify 크롤링 로직 (차트 요약 사이트 활용)
 */
async function crawlSpotify(page) {
    console.log('Spotify: 데이터 수집');
    await page.goto('https://kworb.net/spotify/country/kr_daily.html', { waitUntil: 'networkidle2', timeout: 60000 });
    
    return await page.evaluate(() => {
        const rows = document.querySelectorAll('tbody tr');
        return Array.from(rows).slice(0, 10).map(el => {
            const text = el.querySelector('.text')?.innerText || '';
            const parts = text.split(' - ');
            return {
                title: parts[1]?.trim() || 'Unknown Title',
                artist: parts[0]?.trim() || 'Unknown Artist',
                platform: 'Spotify'
            };
        });
    });
}

/**
 * 3. 메인 실행 함수 (라라벨 스케줄러에 의해 호출됨)
 */
async function run() {
    let browser;
    let connection;

    try {
        console.log('크롤링 프로세스 시작');
        
        browser = await puppeteer.launch({
            args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage'],
            executablePath: process.env.PUPPETEER_EXECUTABLE_PATH
        });

        const page = await browser.newPage();
        connection = await mysql.createConnection(dbConfig);

        // 메서드 개별 실행
        const scResults = await crawlSoundCloud(page);
        const spResults = await crawlSpotify(page);
        const combinedResults = [...scResults, ...spResults];

        console.log(`📊 총 ${combinedResults.length}개의 트랙을 DB에 저장합니다.`);

        for (const track of combinedResults) {
            // Trend 모델의 fillable 항목들과 매칭
            const sql = `
                INSERT INTO trends (
                    platform, 
                    title, 
                    artist, 
                    \`rank\`, 
                    category, 
                    created_at, 
                    updated_at
                ) 
                VALUES (?, ?, ?, ?, ?, NOW(), NOW())
                ON DUPLICATE KEY UPDATE 
                    title = VALUES(title),
                    artist = VALUES(artist),
                    \`rank\` = VALUES(\`rank\`),
                    updated_at = NOW()
            `;

            await connection.execute(sql, [
                track.platform, // 'SoundCloud' 또는 'Spotify'
                track.title, 
                track.artist, 
                track.rank,     // 순위 정보 추가
                'Top 10',       // 카테고리 예시
            ]);
        }

        console.log('모든 데이터 동기화 완료!');
        process.exit(0); // 성공 종료

    } catch (error) {
        console.error('크롤링 실패:', error.message);
        process.exit(1); // 에러 종료
    } finally {
        if (browser) await browser.close();
        if (connection) await connection.end();
    }
}

// 즉시 실행
run();