#! /usr/bin/env bash
set -eu

confirm=1
target='/mnt'
pool='intrepid'
unmount=0
disable_cache=0

help_message="$(
cat <<- EOF
	Synopsis:
		Use this script after partitioning to recursively unmount the target,
		invalidate zpool cache, and export the pool to ensure that the pool
		can be imported without forcing after a reboot.

	Usage:
		$(basename "$0") [-y][-h][-t <p>][-p <l>][-u][-c]

	Options:
		-y | --no-confirm
			Skip confirmation and performs changes immediately.
		-h | --help
			Display this help message.
		-t <path> | --target <path>
			Specify an alternate path to the root of a filesystem,
			for example '/mnt' or '/target'.
		-p <label> | --pool <label>
			Specify the ZFS pool to export.
		-u | --unmount
			Unmount the root filesystem, export the pool,
			and do nothing else (unless specified).
		-c | --disable-cache
			Disable/invalidate the cache and do nothing else (unless specified).

	Notes:
		- If neither '-u' or '-c' are specified, the default is to perform
			both actions.
EOF
)"

while [ $# -ne 0 ]; do
	case "$1" in
		-y|--no-confirm)
			confirm=0
			shift
			;;
		-h|--help)
			echo "$help_message"
			exit 0
			;;
		-t|--target)
			target="$2"
			shift 2
			;;
		-p|--pool)
			pool="$2"
			shift 2
			;;
		-u|--unmount)
			unmount=1
			shift
			;;
		-c|--disable-cache)
			disable_cache=1
			shift
			;;
		*)
			echo "Unknown option: $1"
			exit 1
			;;
	esac
done

# if neither flag has been specified, the default is to perform both
if [ $disable_cache -eq 0 ] && [ $unmount -eq 0 ]; then
	disable_cache=1
	unmount=1
fi

if [ $confirm -eq 1 ]; then
	echo 'You are about to:'

	if [ $disable_cache -eq 1 ]; then
		echo "- modify the permissions of '$target/etc/zfs/zpool.cache'"
	fi

	if [ $unmount -eq 1 ]; then
		echo "- recursively unmount '$target'"
		echo "- export zpool '$pool'"
	fi

	echo
	echo 'Do you want to continue? [Y/n]'

	while true; do
		read -r -p "> " approve

		case $approve in
			[Yy]*)
				break
				;;
			[Nn]*)
				echo 'No changes have been written to the filesystem.'
				exit 50
				;;
			*)
				echo 'Please answer Y to continue or N to abort.'
				;;
		esac
	done
fi

check_su () {
	if [ "$EUID" -ne 0 ]; then
		echo "Please run this script as superuser."
		exit 100
	fi
}

disable_cache () {
	set -x +e

	mkdir -p "$target/etc/zfs/"
	rm -f "$target/etc/zfs/zpool.cache"
	touch "$target/etc/zfs/zpool.cache"
	chmod a-w "$target/etc/zfs/zpool.cache"
	chattr +i "$target/etc/zfs/zpool.cache"

	set +x -e
}

unmount () {
	umount -Rl "$target"
	zpool export "$pool"
}

check_su

[ $disable_cache -eq 1 ] && disable_cache
[ $unmount -eq 1 ] && unmount
