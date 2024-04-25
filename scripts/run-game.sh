#! /usr/bin/env bash
set -eu

if [ "$(id -u)" -eq 0 ]; then
	echo "Running as root, renicing process: $1"
	renice -n -19 -p "$1"
	exit 0
fi

capture_log=0
game_name=''
self_name="$(basename "$0")"; self_name="${self_name%.*}"
logs_dir="$HOME/.${self_name}/logs"

while [[ $# -gt 0 ]]; do
	case "$1" in
		--)
			shift 1
			break
			;;
		--log|-L)
			capture_log=1
			game_name="$2"
			shift 2
			;;
		*)
			echo "Bad argument: $*"
			exit 1
			;;
	esac
done


if [[ $# -lt 1 ]]; then
	echo "No command provided"
	exit 2
fi
cmd=("$@")

set -m
if [[ $capture_log -eq 1 ]]; then
	mkdir -p "$logs_dir"
	log_file="$logs_dir/$game_name.log"
	echo "Enabled logging to: $log_file"
	exec "${cmd[@]}" >>"$log_file" 2>&1 &
else
	exec "${cmd[@]}" &
fi

pid=$!
# Recursively call the script to renice the game's PID.
# This is done so that this script can be trusted in the sudoers file,
# and the only thing that can be done is renice an existing game.
sudo "$0" $pid
fg 1
