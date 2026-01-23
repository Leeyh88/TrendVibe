FROM node:22-alpine

# Puppeteer 실행에 필요한 Chromium 및 한글 폰트 설치
RUN apk add --no-cache \
      chromium \
      nss \
      freetype \
      harfbuzz \
      ca-certificates \
      ttf-freefont \
      font-noto-cjk

# 환경변수: Puppeteer가 설치된 크롬을 찾을 수 있도록 설정
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

WORKDIR /app

# 의존성 설치 (캐시 최적화를 위해 package.json 먼저 복사)
COPY package*.json ./
RUN npm install

# 전체 소스 복사
COPY . .

# 실행
CMD ["node", "index.js"]