#!/bin/bash
set -e

cd /etc/nginx/sites-enabled

# After=block_device.service なので以下は必ず成功する
while [ ! -e letsencrypt ]; do sleep 1; done

systemctl restart nginx


mkdir -p /mnt/data/letsencrypt

mv /etc/letsencrypt/* /mnt/data/letsencrypt/

rm -rf /etc/letsencrypt
ln -s /mnt/data/letsencrypt /etc/letsencrypt



certbot certonly --webroot -w /var/www/html --agree-tos -m ${CERTBOT_EMAIL} -d ${DOMAIN_NAME}

ln -sf /etc/nginx/sites-available/grafana
systemctl restart nginx
