#!/usr/bin/env bash

if [[ -z "$1" ]]; then
	echo "disk argument empty"
	exit 1
fi

DISK="$1"

read -p "About to zap disk $DISK, Are you sure? (y/n):" -n 1 -r

echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	exit 1
fi

# Zap the disk to a fresh, usable state (zap-all is important, b/c MBR has to be clean)

# You will have to run this step for all disks.
PKG="gdisk"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $PKG | grep "install ok installed")
echo Checking for $PKG: "$PKG_OK"
if [ "" = "$PKG_OK" ]; then
	echo "No $PKG. installing."
	apt install -y $PKG
fi

sgdisk --zap-all $DISK

# Clean hdds with dd
dd if=/dev/zero of="$DISK" bs=1M count=100 oflag=direct,dsync

# Clean disks such as ssd with blkdiscard instead of dd
blkdiscard $DISK

# These steps only have to be run once on each node
# If rook sets up osds using ceph-volume, teardown leaves some devices mapped that lock the disks.
ls /dev/mapper/ceph-* | xargs -I% -- dmsetup remove %

# ceph-volume setup can leave ceph-<UUID> directories in /dev and /dev/mapper (unnecessary clutter)
rm -rf /dev/ceph-*
rm -rf /dev/mapper/ceph--*

# Inform the OS of partition table changes
partprobe $DISK
