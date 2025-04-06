#!/bin/bash
set -e

mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | tee /etc/apt/sources.list.d/grafana.list
apt-get update
apt-get install alloy


# docker ログ を読むために docker グループに追加
usermod -aG docker alloy
# gpasswd -d alloy docker


systemctl enable alloy
systemctl start alloy
