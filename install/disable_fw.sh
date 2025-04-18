#!/bin/bash
set -e

iptables -F
iptables -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
systemctl stop netfilter-persistent
systemctl disable netfilter-persistent
netfilter-persistent save
