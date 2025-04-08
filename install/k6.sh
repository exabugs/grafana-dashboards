#!/bin/bash
set -e

wget https://github.com/grafana/k6/releases/download/v1.0.0-rc1/k6-v1.0.0-rc1-linux-arm64.tar.gz
tar -xzf k6-v1.0.0-rc1-linux-arm64.tar.gz
mv k6-v1.0.0-rc1-linux-arm64/k6 /usr/local/bin

rm -rf k6-v1.0.0-rc1-linux-arm64*


