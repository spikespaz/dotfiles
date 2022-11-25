#! /usr/bin/env bash
set -eux

if [ "$(id -u)" -ne 0 ]; then
	echo 'Script must be run as root!'
	exit 1
fi

lockfile='/var/lock/disable-input-devices.lock'
IFS=':' read -ra DISABLE_DEVICES <<< "$DISABLE_DEVICES"

case "$1" in
	disable)
		pids=()
		for device in "${DISABLE_DEVICES[@]}"; do
			evtest --grab "$device" &> /dev/null &
			pids+=($!)
			echo "${pids[-1]}" >> "$lockfile"
		done
		echo "${pids[@]}"
		;;
	release)
		mapfile -t evtest_pids < "$lockfile"
		kill "${evtest_pids[@]}" || true
		rm -f "$lockfile"
		;;
esac
