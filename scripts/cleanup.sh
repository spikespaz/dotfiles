#! /usr/bin/env bash
set -eu

confirm=1
target='/mnt'
pool='ospool'

help_message="$(
cat <<- EOF
	Synopsis:
	  Use this script after partitioning to
	  recursively unmount the target, invalidate zpool cache, and export the pool
	  to ensure that the pool can be imported without forcing after reboot.

	Usage:
	  $(basename "$0") [-y][-h][-t][-p]

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
EOF
)"

cleanup () {
	set -x

	mkdir -p "$target/etc/zfs/"
	rm -f "$target/etc/zfs/zpool.cache"
	touch "$target/etc/zfs/zpool.cache"
	chmod a-w "$target/etc/zfs/zpool.cache"
	chattr +i "$target/etc/zfs/zpool.cache"

	umount -Rl "$target"
	zpool export "$pool"

	set +x
}

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
			shift
			;;
		*)
			echo "Unknown option: $1"
			exit 1
			;;
	esac
done

if [ $confirm -eq 1 ]; then
	cat <<- EOF
		You are about to modify the permissions of '$target/etc/zfs/zpool.cache',
		recursively unmount '$target", and export zpool '$pool'.

		Do you want to continue? [Y/n]
	EOF

	while true; do
    read -r -p "> " approve

    case $approve in
        [Yy]*)
					cleanup
					exit 0
					;;
        [Nn]*)
					echo 'No changes have been written to the filesystem.'
					exit 2
					;;
        *)
					echo 'Please answer Y to continue or N to abort.'
					;;
    esac
	done
fi
