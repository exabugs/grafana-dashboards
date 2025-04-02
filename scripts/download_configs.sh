#!/bin/bash
set -e

mkdir -p /opt/{prometheus,compose}
curl -fsSL $SERVER_SETUP_SITE/prometheus/prometheus.yml -o /opt/prometheus/prometheus.yml
curl -fsSL $SERVER_SETUP_SITE/compose/docker-compose.yml -o /opt/compose/docker-compose.yml

# Nginx sites
mkdir -p /etc/nginx/sites-available
available=(
  default
  grafana
)
for site in "${available[@]}"; do
  path=/etc/nginx/sites-available/$site
  curl -fsSL $SERVER_SETUP_SITE/nginx/$site.conf -o $path
  envsubst < "$path" > "${path}.tmp" && mv "${path}.tmp" "$path"
done

# Grafana provisioning
mkdir -p /opt/grafana/provisioning/{dashboards,datasources}
provs=(
  dashboards/default.yml
  dashboards/node-exporter.json
  datasources/prometheus.yml
)
for service in "${provs[@]}"; do
  curl -fsSL $SERVER_SETUP_SITE/provisioning/$service -o /opt/grafana/provisioning/$service
done

# Services
mkdir -p /opt/setup
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
