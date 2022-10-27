#! /usr/bin/env bash

sudo -s <<- EOF
	sudo umount -R /mnt
	sudo zpool export ospool
EOF
