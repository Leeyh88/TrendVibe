FROM node:22-alpine

# 1. Puppeteer 실행에 필요한 Chromium 및 한글 폰트 설치
RUN apk add --no-cache \
      chromium \
      nss \
      freetype \
      harfbuzz \
      ca-certificates \
      ttf-freefont \
      font-noto-cjk

# 2. 환경변수 설정
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

WORKDIR /app

# 3. 패키지 파일 먼저 복사 (빌드 캐시 활용)
COPY package*.json ./

# 4. 필수 패키지 설치 (@google/generative-ai 최신버전 포함)
RUN npm install puppeteer mysql2 @google/generative-ai

# 5. 소스 코드 복사
COPY . .

# 6. 실행 설정
# 테스트 기간에는 tail로 띄워두고, 완성이 되면 node index.js로 수정예정
CMD ["tail", "-f", "/dev/null"]