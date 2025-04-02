#!/bin/bash
set -e

mkdir -p \
  /opt/{setup,grafana,prometheus,compose} \
  /opt/grafana/provisioning/{dashboards,datasources} \
  /etc/nginx/{sites-available,sites-enabled}

curl -fsSL $SERVER_SETUP_SITE/prometheus/prometheus.yml -o /opt/prometheus/prometheus.yml
curl -fsSL $SERVER_SETUP_SITE/compose/docker-compose.yml -o /opt/compose/docker-compose.yml

cd /etc/nginx/sites-available
curl -fsSL $SERVER_SETUP_SITE/nginx/letsencrypt.conf -o letsencrypt
curl -fsSL $SERVER_SETUP_SITE/nginx/grafana.conf -o grafana
sed -i "s/DOMAIN_NAME/${DOMAIN_NAME}/g" {letsencrypt,grafana}

cd /opt/grafana/provisioning
curl -fsSL $SERVER_SETUP_SITE/provisioning/dashboards/default.yml -o dashboards/default.yml
curl -fsSL $SERVER_SETUP_SITE/provisioning/dashboards/node-exporter.json -o dashboards/node-exporter.json
curl -fsSL $SERVER_SETUP_SITE/provisioning/datasources/prometheus.yml -o datasources/prometheus.yml

cd /opt/setup
curl -fsSL $SERVER_SETUP_SITE/scripts/download_configs.sh -o download_configs.sh
curl -fsSL $SERVER_SETUP_SITE/scripts/block_device.sh -o block_device.sh
curl -fsSL $SERVER_SETUP_SITE/scripts/letsencrypt_config.sh -o letsencrypt_config.sh
curl -fsSL $SERVER_SETUP_SITE/scripts/grafana.sh -o grafana.sh
curl -fsSL $SERVER_SETUP_SITE/scripts/node_exporter.sh -o node_exporter.sh
chmod +x *

cd /etc/systemd/system
curl -fsSL $SERVER_SETUP_SITE/systemd/download_configs.service -o download_configs.service
curl -fsSL $SERVER_SETUP_SITE/systemd/grafana.service -o grafana.service
curl -fsSL $SERVER_SETUP_SITE/systemd/node_exporter.service -o node_exporter.service
curl -fsSL $SERVER_SETUP_SITE/systemd/block_device.service -o block_device.service
curl -fsSL $SERVER_SETUP_SITE/systemd/letsencrypt_config.service -o letsencrypt_config.service

cd /etc/nginx/sites-enabled
rm -f default
ln -sf /etc/nginx/sites-available/letsencrypt

systemctl daemon-reload
