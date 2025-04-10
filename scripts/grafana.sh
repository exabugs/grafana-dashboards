#!/bin/bash
set -e

# Grafana & Prometheus のデータを保存するマウントポイント
MOUNTPOINT=/mnt/data

# 作業ディレクトリ（docker-compose.yml がある場所）
WORKDIR="/opt/compose"

# Nginx の設定ファイルのパス
GRAFANA_SITE_NAME="grafana"
MIMIR_SITE_NAME="mimir"

# 使用するコマンドの絶対パス（systemd 対策）
DOCKER="/usr/bin/docker"
NGINX="/usr/sbin/nginx"

command -v "$DOCKER" >/dev/null || { err "Docker not found at $DOCKER"; exit 1; }
command -v "$NGINX"  >/dev/null || { err "Nginx not found at $NGINX"; exit 1; }

# 作業ディレクトリに移動
if [ ! -d "$WORKDIR" ]; then
  err "Working directory $WORKDIR does not exist"
  exit 1
fi
cd "$WORKDIR"

log() {
  echo "[INFO] $1"
}

err() {
  echo "[ERROR] $1" >&2
}

start() {
  log "Creating Grafana & Prometheus directories"
  mkdir -p $MOUNTPOINT/{grafana,mimir,prometheus,loki,tempo}
  chown 472:472 $MOUNTPOINT/grafana
  chown 472:472 $MOUNTPOINT/mimir
  chown nobody:nogroup $MOUNTPOINT/prometheus
  chown 10001:10001 $MOUNTPOINT/loki
  chown 10001:10001 $MOUNTPOINT/tempo

  log "Linking Nginx site: $GRAFANA_SITE_NAME"
  ln -sf "/etc/nginx/sites-available/$GRAFANA_SITE_NAME" "/etc/nginx/sites-enabled/$GRAFANA_SITE_NAME"

  log "Linking Nginx site: $MIMIR_SITE_NAME"
  ln -sf "/etc/nginx/sites-available/$MIMIR_SITE_NAME" "/etc/nginx/sites-enabled/$MIMIR_SITE_NAME"

  log "Reloading Nginx"
  $NGINX -t && $NGINX -s reload

  log "Starting Grafana & Prometheus with Docker Compose"
  $DOCKER compose up -d
}

stop() {
  log "Unlinking Nginx site: $GRAFANA_SITE_NAME"
  rm -f "/etc/nginx/sites-enabled/$GRAFANA_SITE_NAME"

  log "Unlinking Nginx site: $MIMIR_SITE_NAME"
  rm -f "/etc/nginx/sites-enabled/$MIMIR_SITE_NAME"

  log "Reloading Nginx"
  $NGINX -t && $NGINX -s reload

  log "Stopping Grafana & Prometheus"
  $DOCKER compose down
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
