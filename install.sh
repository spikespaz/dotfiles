#! /bin/sh
set -eu

nixos-install --flake "path:$(pwd)#"

if grep -qs '/mnt ' /proc/mounts; then
	umount -Rl /mnt
fi

zpool export -a
