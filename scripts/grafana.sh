#!/bin/bash
set -e

# 作業ディレクトリ（docker-compose.yml がある場所）
WORKDIR="/opt/compose"
NGINX="grafana"
DOCKER="/usr/bin/docker"

cd "$WORKDIR"

log() {
  echo "[INFO] $1"
}

err() {
  echo "[ERROR] $1" >&2
}

start() {
  log "Linking Nginx site: $NGINX"
  ln -sf "/etc/nginx/sites-available/$NGINX" "/etc/nginx/sites-enabled/$NGINX"
  nginx -t && nginx -s reload

  log "Starting Grafana & Prometheus with Docker Compose"
  "$DOCKER" compose up -d
}

stop() {
  log "Unlinking Nginx site: $NGINX"
  rm -f "/etc/nginx/sites-enabled/$NGINX"
  nginx -t && nginx -s reload

  log "Stopping Grafana & Prometheus"
  "$DOCKER" compose down
}


case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    log "Restarting via stop + start"
    stop
    start
    ;;
  *)
    err "Usage: $0 {start|stop|restart}"
    exit 1
    ;;
esac
