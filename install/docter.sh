#!/bin/bash
set -e

SERVICES=(
  download_configs
  block_device
  docker
  nginx
  letsencrypt_config
  grafana
)

EXIT_CODE=0

echo "Service"

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


echo "URL"

URLS=(
"http://${DOMAIN_NAME}"
"https://${DOMAIN_NAME}/login"
)
for URL in "${URLS[@]}"; do
  set +e
  status_code=$(curl -o /dev/null -s -w "%{http_code}" "$URL")
  set -e

  if [ "$status_code" -eq 200 ]; then
    echo "✅ OK: $URL is reachable"
  else
    echo "❌ ERROR: $URL returned $status_code"
    EXIT_CODE=1
  fi
done

set +e
nginx -t
RESULT=$?
set -e
if [ "$RESULT" -eq 0 ]; then
  echo "✅ OK: nginx is valid"
else
  echo "❌ ERROR: nginx config not valid"
  EXIT_CODE=1
fi

set +e
oci os ns get --auth instance_principal
RESULT=$?
set -e
if [ "$RESULT" -eq 0 ]; then
  echo "✅ OK: oci cli is redy"
else
  echo "❌ ERROR: oci cli is not ready"
  EXIT_CODE=1
fi

echo "S3 Buckets"
. /opt/compose/.env
BUCKETS=(
"mimir-blocks"
"mimir-ruler"
"mimir-alerts"
)
for BUCKET in "${BUCKETS[@]}"; do
  set +e
  s3cmd ls s3://$BUCKET \
    --host=$S3_ENDPOINT \
    --access_key=$S3_ACCESS_KEY \
    --secret_key=$S3_SECRET_KEY \
    --host-bucket=''
  RESULT=$?
  set -e

  if [ "$RESULT" -eq 0 ]; then
    echo "✅ OK: Bucket $BUCKET is ready"
  else
    echo "❌ ERROR: Bucket $BUCKET is not ready"
    EXIT_CODE=1
  fi
done

exit $EXIT_CODE
