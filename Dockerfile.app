# 사용할 기본 이미지
FROM php:8.4-fpm-alpine

# 필요한 시스템 패키지 설치
RUN apk update && apk add --no-cache \
    postgresql-dev \
    mariadb-client \
    git \
    libzip-dev \
    freetype-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    icu-dev \
    # --- 파이썬 관련 추가 ---
    python3 \
    py3-pip \
    # -----------------------
    && docker-php-ext-install pdo pdo_mysql zip intl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# --- mido 라이브러리 설치 (root 권한에서 실행) ---
RUN pip3 install mido --break-system-packages

# Composer 설치
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 권한 설정
RUN addgroup -g 1000 laravel && adduser -u 1000 -G laravel -s /bin/sh -D laravel
RUN chown -R laravel:laravel /var/www

# 작업 디렉토리 설정
WORKDIR /var/www/html

# 사용자 전환
USER laravel

# 실행 명령어
CMD ["php-fpm"]