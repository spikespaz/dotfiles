#!/usr/bin/env bash

# Co-authored by: ChatGPT 4o

set -euo pipefail

find_rfkill_for_hci() {
	local hci="$1"
	for typefile in /sys/class/rfkill/*/type; do
		if read -r t < "$typefile" && [[ "$t" == "bluetooth" ]]; then
			device_dir="${typefile%/type}"
			if [[ -e "$device_dir/device" ]]; then
				dev_path="$(readlink -f "$device_dir/device")"
				if [[ "$(basename "$dev_path")" == "$hci" ]]; then
					# Extract just the rfkill number
					echo "${device_dir##*/rfkill}"
					return 0
				fi
			fi
		fi
	done
	return 1
}

rfkill_path_from_id() {
	echo "/sys/class/rfkill/rfkill$1"
}

wait_for_hci_controller() {
	local hci="$1"
	for _ in $(seq 1 20); do
		if [[ -e "/sys/class/bluetooth/$hci" ]]; then
			return 0
		fi
		sleep 0.1
	done
	return 1
}

toggle_bluetooth() {
	local hci="$1"
	local rfkill_id
	rfkill_id="$(find_rfkill_for_hci "$hci")" || {
		echo "No rfkill device found for $hci" >&2
		exit 1
	}

	read -r state < "$(rfkill_path_from_id "$rfkill_id")/state"

	if [[ "$state" == "1" ]]; then
		rfkill block "$rfkill_id"
	else
		rfkill unblock "$rfkill_id"
		wait_for_hci_controller "$hci" || {
			echo "Bluetooth controller $hci did not appear after unblock" >&2
			exit 1
		}
	fi
}

open_bluetooth_settings() {
	local hci="$1"
	local rfkill_id
	rfkill_id="$(find_rfkill_for_hci "$hci")" || {
		echo "No rfkill device found for $hci" >&2
		exit 1
	}

	read -r state < "$(rfkill_path_from_id "$rfkill_id")/state"

	if [[ "$state" == "0" ]]; then
		rfkill unblock "$rfkill_id"
		wait_for_hci_controller "$hci" || {
			echo "Bluetooth controller $hci did not appear after unblock" >&2
			exit 1
		}
	fi

	blueman-manager
}

rfkill_block_bluetooth() {
	local hci="$1"
	local rfkill_id
	rfkill_id="$(find_rfkill_for_hci "$hci")" || {
		echo "No rfkill device found for $hci" >&2
		exit 1
	}

	rfkill block "$rfkill_id"
}

kill_bluetooth() {
	rfkill_block_bluetooth "$@"
	systemctl restart bluetooth.service
}

# Main entry

main() {
	local cmd="${1:-}"
	local hci="${2:-hci0}"

	case "$cmd" in
	toggle)
		toggle_bluetooth "$hci"
		;;
	settings)
		open_bluetooth_settings "$hci"
		;;
	rfkill-block)
		rfkill_block_bluetooth "$hci"
		;;
	kill)
		kill_bluetooth "$hci"
		;;
	*)
		echo "Usage: $0 {toggle|settings|rfkill-block|kill} [hciN]" >&2
		exit 1
		;;
	esac
}

main "$@"
