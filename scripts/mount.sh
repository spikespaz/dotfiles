#! /usr/bin/env bash

target='/mnt'
pool='ospool'
boot_label='BOOT'

sudo -s <<- EOF
	zpool import -f -R $target $pool
	mkdir -p $target/boot
	mount -t vfat /dev/disk/by-label/$boot_label $target/boot
EOF
