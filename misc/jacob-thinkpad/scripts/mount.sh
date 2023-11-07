#! /usr/bin/env bash

target="${1:-'/mnt'}"
pool="${2:-'ospool'}"
boot_label="${3:-'BOOT'}"

sudo -s <<- EOF
	zpool import -f -R $target $pool
	mkdir -p $target/boot
	mount -t vfat /dev/disk/by-label/$boot_label $target/boot
EOF
