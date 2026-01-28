const puppeteer = require('puppeteer');
const mysql = require('mysql2/promise');

// DB 설정
const dbConfig = {
    host: process.env.DB_HOST || 'mariadb',
    user: process.env.DB_USER || 'tm_user',
    password: process.env.DB_PASS || 'tm_password',
    database: process.env.DB_NAME || 'tv_db',
};

/**
 * 스포티파이 크롤링 및 직접 파싱 로직
 */
async function crawlSpotify(page, url, category) {
    console.log(`Spotify (${category}): 데이터 수집 및 파싱 시작...`);
    try {
        await page.goto(url, { waitUntil: 'networkidle2', timeout: 60000 });

        // 트랙 리스트 레이아웃이 로드될 때까지 대기
        await page.waitForSelector('[data-testid="tracklist-row"]', { timeout: 10000 });

        // 브라우저 컨텍스트 내에서 직접 데이터 추출
        const tracks = await page.evaluate((categoryName) => {
            const rows = Array.from(document.querySelectorAll('[data-testid="tracklist-row"]'));
            
            // 상위 10개만 추출
            return rows.slice(0, 10).map((row) => {
                // 1. 순위 추출
                const rankText = row.querySelector('.V_m9tLr8WFA3JGMYxfIC span')?.innerText || "0";
                
                // 2. 제목 및 트랙 ID 추출
                const titleElement = row.querySelector('a[data-testid="internal-track-link"]');
                const title = titleElement?.innerText || "Unknown";
                const trackHref = titleElement?.getAttribute('href') || "";
                const external_id = trackHref.split('/track/')[1] || null;

                // 3. 아티스트 추출 (여러 명일 경우 쉼표로 연결)
                const artistLinks = Array.from(row.querySelectorAll('a[href*="/artist/"]'));
                const artist = artistLinks.map(el => el.innerText.trim()).join(', ') || "Unknown";

                // 4. 앨범 커버 URL 추출
                const imgElement = row.querySelector('img');
                const album_cover_url = imgElement?.src || null;

                return {
                    rank: parseInt(rankText, 10),
                    title: title.trim(),
                    artist: artist.trim(),
                    album_cover_url: album_cover_url,
                    external_id: external_id,
                    category: categoryName
                };
            });
        }, category);

        console.log(`${category} 파싱 완료: ${tracks.length}곡 발견`);
        return tracks;
    } catch (e) {
        console.error(`${category} 크롤링 실패:`, e.message);
        return [];
    }
}

async function run() {
    let browser;
    let connection;

    try {
        browser = await puppeteer.launch({
            args: ['--no-sandbox', '--disable-setuid-sandbox'],
            executablePath: process.env.PUPPETEER_EXECUTABLE_PATH
        });
        const page = await browser.newPage();
        
        // 브라우저 에이전트 설정 (차단 방지)
        await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36');

        connection = await mysql.createConnection(dbConfig);

        // 1. 데이터 수집 (글로벌/코리아)
        const globalData = await crawlSpotify(page, 'https://open.spotify.com/playlist/37i9dQZEVXbMDoHDwVN2tF', 'Global');
        const koreaData = await crawlSpotify(page, 'https://open.spotify.com/playlist/37i9dQZEVXbJZGli0rRP3r', 'Korea');

        const allTracks = [...globalData, ...koreaData];

        // 2. DB 저장 (UPSERT 로직)
        for (const track of allTracks) {
            const sql = `
                INSERT INTO trends (platform, category, \`rank\`, title, artist, album_cover_url, external_id, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
                ON DUPLICATE KEY UPDATE
                    title = VALUES(title),
                    artist = VALUES(artist),
                    album_cover_url = VALUES(album_cover_url),
                    external_id = VALUES(external_id),
                    updated_at = NOW()
            `;
            
            await connection.execute(sql, [
                'Spotify', 
                track.category, 
                track.rank, 
                track.title, 
                track.artist, 
                track.album_cover_url, 
                track.external_id
            ]);
        }
        console.log(`총 ${allTracks.length}개의 데이터를 DB에 성공적으로 업데이트했습니다!`);

    } catch (error) {
        console.error('실행 중 에러:', error.message);
    } finally {
        if (browser) await browser.close();
        if (connection) await connection.end();
        process.exit(0);
    }
}

run();
