#!/bin/bash
set -e

# 永続化
mkdir -p /mnt/data/letsencrypt
if [ ! -L /etc/letsencrypt ]; then
  rsync -a /etc/letsencrypt/ /mnt/data/letsencrypt/
  rm -rf /etc/letsencrypt
  ln -s /mnt/data/letsencrypt /etc/letsencrypt
fi

# certbot 実行
certbot certonly \
  --webroot -w /var/www/html \
  --agree-tos \
  --keep-until-expiring \
  --non-interactive \
  -m "${CERTBOT_EMAIL}" \
  -d "${DOMAIN_NAME}" || exit 1
