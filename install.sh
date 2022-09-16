#!/bin/sh
set -e

#./partition.sh

NIXPKGS_ALLOW_BROKEN=1
nixos-install --flake path:$(pwd)#

if grep -qs '/mnt ' /proc/mounts; then
	umount -Rl /mnt
fi

zpool export -a
