#! /usr/bin/env bash
set -u

if [ "$(id -u)" -ne 0 ]; then
	echo 'Script must be run as superuser!'
	exit 1
fi

case "$1" in
	disable)
		shift 1
		pids=()
		for event in "$@"; do
			evtest --grab "$event" &> /dev/null &
			pids+=($!)
		done
		echo "${pids[@]}"
		;;
	release)
		shift 1
		# shellcheck disable=SC2068
		kill $@
		;;
esac
