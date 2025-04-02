#!/bin/bash
set -e

mkdir -p \
  /opt/{setup,grafana,prometheus,compose} \
  /opt/grafana/provisioning/{dashboards,datasources} \
  /etc/nginx/{sites-available,sites-enabled}

curl -fsSL $SERVER_SETUP_SITE/prometheus/prometheus.yml -o /opt/prometheus/prometheus.yml
curl -fsSL $SERVER_SETUP_SITE/compose/docker-compose.yml -o /opt/compose/docker-compose.yml

cd /etc/nginx/sites-available
curl -fsSL $SERVER_SETUP_SITE/nginx/default.conf -o default
curl -fsSL $SERVER_SETUP_SITE/nginx/grafana.conf -o grafana
sed -i "s/DOMAIN_NAME/${DOMAIN_NAME}/g" {default,grafana}

cd /opt/grafana/provisioning
curl -fsSL $SERVER_SETUP_SITE/provisioning/dashboards/default.yml -o dashboards/default.yml
curl -fsSL $SERVER_SETUP_SITE/provisioning/dashboards/node-exporter.json -o dashboards/node-exporter.json
curl -fsSL $SERVER_SETUP_SITE/provisioning/datasources/prometheus.yml -o datasources/prometheus.yml

services=(
  download_configs
  block_device
  letsencrypt_config
  grafana
  node_exporter
)

for service in "${services[@]}"; do
  curl -fsSL $SERVER_SETUP_SITE/scripts/$service.sh -o /opt/setup/$service.sh
  curl -fsSL $SERVER_SETUP_SITE/systemd/$service.service -o /etc/systemd/system/$service.service
  chmod +x /opt/setup/$service.sh
  systemctl enable $service
done

systemctl daemon-reload
