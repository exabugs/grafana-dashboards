#!/bin/bash
set -e

curl -fLo mimirtool https://github.com/grafana/mimir/releases/latest/download/mimirtool-linux-arm64
chmod +x mimirtool
mv mimirtool /usr/local/bin/mimirtool
