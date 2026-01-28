#!/bin/bash
cd /home/ubuntu/TrendVibe
# 1. 인증서 갱신 시도
/usr/bin/docker run --rm --name certbot \
  -v "$(pwd)/certbot/conf:/etc/letsencrypt" \
  -v "$(pwd)/certbot/www:/var/www/certbot" \
  certbot/certbot renew --quiet

# 2. Nginx에 새 인증서 반영 (재시작 없이 설정만 리로드)
/usr/bin/docker-compose exec -T web nginx -s reload
