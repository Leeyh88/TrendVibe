# 사용할 기본 이미지 (PHP 8.2-fpm-alpine 예시)
FROM php:8.4-fpm-alpine

# 필요한 시스템 패키지 설치
# mariadb-client: DB 연결 도구
# freetype, libpng, libjpeg: GD 라이브러리 지원
RUN apk update && apk add --no-cache \
    postgresql-dev \
    mariadb-client \
    git \
    libzip-dev \
    freetype-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    icu-dev \
    # 다른 필요한 시스템 라이브러리를 여기에 추가할 수 있습니다.
    && docker-php-ext-install pdo pdo_mysql zip intl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# Composer 설치 (Laravel 의존성 관리 도구)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 권한 설정: Laravel은 www-data 사용자로 실행되는 것이 일반적입니다.
RUN addgroup -g 1000 laravel && adduser -u 1000 -G laravel -s /bin/sh -D laravel
RUN chown -R laravel:laravel /var/www
USER laravel

# 작업 디렉토리 설정 (docker-compose.yml에서 마운트할 위치)
WORKDIR /var/www/html

# 실행 명령어: PHP-FPM을 실행합니다.
CMD ["php-fpm"]
