#!/bin/bash
set -e

mkdir -p \
  /opt/{setup,grafana,prometheus,compose} \
  /opt/grafana/provisioning/{dashboards,datasources} \
  /etc/nginx/{sites-available,sites-enabled}

curl -fsSL $SERVER_SETUP_SITE/prometheus/prometheus.yml -o /opt/prometheus/prometheus.yml
curl -fsSL $SERVER_SETUP_SITE/compose/docker-compose.yml -o /opt/compose/docker-compose.yml

# Nginx sites
available=(
  default
  grafana
)
for site in "${available[@]}"; do
  curl -fsSL $SERVER_SETUP_SITE/nginx/$site.conf -o /etc/nginx/sites-available/$site
  sed -i "s/DOMAIN_NAME/${DOMAIN_NAME}/g" /etc/nginx/sites-available/$site
done

# Grafana provisioning
provs=(
  dashboards/default.yml
  dashboards/node-exporter.json
  datasources/prometheus.yml
)
for service in "${services[@]}"; do
  curl -fsSL $SERVER_SETUP_SITE/provisioning/$service -o /opt/grafana/provisioning/$service
done

# Services
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
