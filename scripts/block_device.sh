#!/bin/bash
set -e

DEVICE=/dev/sdb
MOUNTPOINT=/mnt/data

if [ ! -b "$DEVICE" ]; then
    echo "Block device $DEVICE not found"
    exit 1
fi

if ! blkid "$DEVICE"; then
    echo "No filesystem found on $DEVICE, formatting as ext4"
    mkfs.ext4 -F "$DEVICE"
else
    echo "$DEVICE already has a filesystem, skipping format"
    resize2fs "$DEVICE" || true
fi

mkdir -p $MOUNTPOINT
grep -q "$MOUNTPOINT" /etc/fstab || echo "$DEVICE $MOUNTPOINT ext4 defaults,nofail 0 2" >> /etc/fstab
mount -a

if [ -z "$(ls -A $MOUNTPOINT)" ]; then
    echo "$MOUNTPOINT is empty. Setting owner to ubuntu."
    chown -R ubuntu:ubuntu $MOUNTPOINT
else
    echo "$MOUNTPOINT is not empty. Skipping chown."
fi

