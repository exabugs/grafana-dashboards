#!/bin/bash
set -e

SERVICES=(
  download-configs
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

  if [ "$RESULT" -eq 0 ] && [ "$STATUS" = "active" ]; then
    echo "✅ $SERVICE is running."
  else
    echo "❌ $SERVICE is NOT running. Status: ${STATUS:-unknown}"
    EXIT_CODE=1
  fi
done

exit $EXIT_CODE
