#!/bin/sh
set -e

#./partition.sh
mkdir -p /mnt/etc/nixos
cp configuration.nix /mnt/etc/nixos/
NIXPKGS_ALLOW_BROKEN=1 & nixos-install
umount -Rl /mnt
zpool export -a

