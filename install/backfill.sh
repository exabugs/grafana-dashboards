



curl -fLo mimirtool https://github.com/grafana/mimir/releases/latest/download/mimirtool-linux-arm64
chmod +x mimirtool



mimirtool backfill --address=http://localhost:9009/ --id=anonymous /mnt/data/prometheus/data/01*
