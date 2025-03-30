#!/bin/bash
set -e

VER=1.9.0
wget https://github.com/prometheus/node_exporter/releases/download/v${VER}/node_exporter-${VER}.linux-arm64.tar.gz
tar xvfz node_exporter-${VER}.linux-arm64.tar.gz
sudo cp node_exporter-${VER}.linux-arm64/node_exporter /usr/local/bin/
sudo chown root:root /usr/local/bin/node_exporter


if ! id -u node_exporter >/dev/null 2>&1; then
  sudo useradd --no-create-home --shell /bin/false node_exporter
fi
