#! /usr/bin/env bash

sudo -s <<- EOF
	zpool import -f -R /mnt ospool
	mount -t vfat /dev/disk/by-label/BOOT /mnt/boot
EOF
