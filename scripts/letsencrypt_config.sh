#!/bin/bash
set -e

cd /etc/nginx/sites-enabled

# After=block_device.service なので以下は必ず成功する
# while [ ! -e letsencrypt ]; do sleep 1; done

# リンク削除
# rm -f /etc/nginx/sites-enabled/grafana
# systemctl restart nginx

# letsencrypt の永続化
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

# # Nginx の再設定
# ln -sf /etc/nginx/sites-available/grafana /etc/nginx/sites-enabled/grafana
# nginx -t && systemctl reload nginx