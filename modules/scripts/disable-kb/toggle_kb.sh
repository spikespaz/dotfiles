#! /usr/bin/env bash
set -eu

if [ "$(id -u)" -ne 0 ]; then
	echo 'Script must be run as root!'
	exit 1
fi

lockfile='/var/lock/disable-input-devices.lock'
IFS=':' read -ra DISABLE_DEVICES <<< "$DISABLE_DEVICES"

case "$1" in
	disable)
		for device in "${DISABLE_DEVICES[@]}"; do
			evtest --grab "$device" &> /dev/null &
			echo "$!" >> "$lockfile"
		done
		;;
	release)
		mapfile -t evtest_pids < "$lockfile"
		# shellcheck disable=SC2068
		kill ${evtest_pids[@]} || true
		rm -f "$lockfile"
		;;
esac
