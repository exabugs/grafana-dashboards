#!/bin/bash
set -e

SERVICES=(
  download_configs
  block_device
  docker
  nginx
  letsencrypt_config
  grafana
  node_exporter
)

EXIT_CODE=0

for SERVICE in "${SERVICES[@]}"; do
  set +e
  STATUS=$(systemctl is-active "$SERVICE" 2>/dev/null)
  RESULT=$?
  set -e

  case "$STATUS" in
    active)
      echo "✅ $SERVICE is running. [active]"
      ;;
    inactive)
      echo "⚠️  $SERVICE is installed but not running. [inactive]"
      EXIT_CODE=1
      ;;
    failed)
      echo "❌ $SERVICE has failed. Check logs. [failed]"
      EXIT_CODE=1
      ;;
    activating)
      echo "⏳ $SERVICE is starting up. [activating]"
      ;;
    deactivating)
      echo "⏸️  $SERVICE is stopping. [deactivating]"
      ;;
    reloading)
      echo "🔁 $SERVICE is reloading configuration. [reloading]"
      ;;
    "")
      echo "❓ $SERVICE status unknown or service not found. [unknown]"
      EXIT_CODE=1
      ;;
    *)
      echo "❗ $SERVICE returned unexpected status: $STATUS"
      EXIT_CODE=1
      ;;
  esac
done

exit $EXIT_CODE
