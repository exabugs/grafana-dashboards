#!/bin/bash
set -e

VER="1.9.0"
BINARY_PATH="/usr/local/bin/node_exporter"
TARBALL="node_exporter-${VER}.linux-arm64.tar.gz"
URL="https://github.com/prometheus/node_exporter/releases/download/v${VER}/${TARBALL}"
TMP_DIR="/tmp/node_exporter_${VER}"

# ユーザ固定
USER="node_exporter"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

err() {
  echo "ERROR: $*" >&2
}

install() {
  if [ -x "$BINARY_PATH" ]; then
    log "node_exporter is already installed at $BINARY_PATH"
    return
  fi

  log "Downloading node_exporter ${VER}"
  mkdir -p "$TMP_DIR"
  cd "$TMP_DIR"
  wget -q "$URL"
  tar xzf "$TARBALL"

  log "Installing binary"
  cp "node_exporter-${VER}.linux-arm64/node_exporter" "$BINARY_PATH"
  chown root:root "$BINARY_PATH"
  chmod 755 "$BINARY_PATH"

  if ! id -u "$USER" >/dev/null 2>&1; then
    log "Creating user: $USER"
    useradd --no-create-home --shell /bin/false "$USER" --user-group
  fi

  log "Installation completed"
}

start() {
  install || exit 1
  exec runuser -u "$USER" -- /usr/local/bin/node_exporter
}

stop() {
  log "Nothing to stop in install script"
}

restart() {
  log "Restarting: stop + start"
  stop
  start
}

case "$1" in
  install)
    install
    ;;
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    restart
    ;;
  *)
    err "Usage: $0 {install|start|stop|restart}"
    exit 1
    ;;
esac
