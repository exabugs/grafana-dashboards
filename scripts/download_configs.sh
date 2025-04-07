#!/bin/bash
set -e

# Doctor
curl -fsSL $SERVER_SETUP_SITE/install/docter.sh -o /root/docter.sh
chmod +x /root/docter.sh


# prometheus
mkdir -p /opt/prometheus
curl -fsSL $SERVER_SETUP_SITE/prometheus/prometheus.yml -o /opt/prometheus/prometheus.yml

# mimir
mkdir -p /opt/mimir
curl -fsSL $SERVER_SETUP_SITE/mimir/mimir.yml -o /opt/mimir/mimir.yml

# alloy
mkdir -p /opt/alloy
curl -fsSL $SERVER_SETUP_SITE/alloy/config.alloy -o /etc/alloy/config.alloy

# loki
mkdir -p /opt/loki
curl -fsSL $SERVER_SETUP_SITE/loki/loki.yml -o /opt/loki/loki.yml

# docker compose
mkdir -p /opt/compose
curl -fsSL $SERVER_SETUP_SITE/compose/docker-compose.yml -o /opt/compose/docker-compose.yml

# Nginx sites
mkdir -p /etc/nginx/sites-available
available=(
  default
  grafana
  mimir
)
for site in "${available[@]}"; do
  path=/etc/nginx/sites-available/$site
  curl -fsSL $SERVER_SETUP_SITE/nginx/$site.conf -o $path
  sed -i "s/\${DOMAIN_NAME}/${DOMAIN_NAME}/g" $path
done

# Grafana provisioning
mkdir -p /opt/grafana/provisioning/{dashboards,datasources,alerting,plugins}
provs=(
  dashboards/default.yml
  dashboards/node-exporter.json
  datasources/mimir.yml
)
for service in "${provs[@]}"; do
  curl -fsSL $SERVER_SETUP_SITE/provisioning/$service -o /opt/grafana/provisioning/$service
done

# Services
mkdir -p /opt/setup
services=(
  block_device
  letsencrypt_config
  grafana
  mimir
)
for service in "${services[@]}"; do
  path=/opt/setup/$service.sh
  curl -fsSL $SERVER_SETUP_SITE/scripts/$service.sh -o $path
  chmod +x $path
done
for service in "${services[@]}"; do
  curl -fsSL $SERVER_SETUP_SITE/systemd/$service.service -o /etc/systemd/system/$service.service
  systemctl enable $service
done

systemctl daemon-reload
