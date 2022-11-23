#! /usr/bin/env bash

set -eux

if [ "$(id -u)" -eq 0 ]; then
	if [ "$1" == 'disable' ]; then
		shift 1
		pids=()
		for event in "$@"; do
			evtest --grab "$event" &> /dev/null &

			pids+=($!)
		done
		echo "${pids[@]}"
	elif [ "$1" == 'release' ]; then
		shift 1
		# shellcheck disable=SC2068
		kill $@
	fi
	exit 0
fi

IFS=':' read -ra DISABLE_DEVICES <<< "$DISABLE_DEVICES"
device_count=${#DISABLE_DEVICES[@]}

: "${DISABLE_DURATION:=30}"
: "${NOTIFICATION_USER:=${SUDO_USER-$USER}}"
: "${NOTIFICATION_COUNTDOWN:=28}"
: "${NOTIFICATION_TIMEOUT:=2000}"
: "${NOTIFICATION_TEXT_SIZE:=x-large}"
: "${NOTIFICATION_ICON_CATEGORY:=devices}"
: "${NOTIFICATION_ICON_NAME:=input-keyboard}"
: "${NOTIFICATION_URGENCY:=critical}"
: "${NOTIFICATION_TITLE:=Input/Keyboard}"

__NOTIFICATION_COUNTDOWN_TIMEOUT=2000

echo "$0"

pids=("$(sudo "$0" disable "${DISABLE_DEVICES[@]}")")

notify-send \
	"$NOTIFICATION_TITLE" \
	"<b><span size='$NOTIFICATION_TEXT_SIZE'>Disabled</span></b>\\n$device_count devices" \
	-u $NOTIFICATION_URGENCY \
	-t $NOTIFICATION_TIMEOUT \
	-c $NOTIFICATION_ICON_CATEGORY \
	-i $NOTIFICATION_ICON_NAME \
	-h string:synchronous:disable-keyboard

sleep $((DISABLE_DURATION - NOTIFICATION_COUNTDOWN))

for i in $(seq 0 $NOTIFICATION_COUNTDOWN); do
	i=$((NOTIFICATION_COUNTDOWN - i))
	notify-send \
		"$NOTIFICATION_TITLE" \
		"Enabling ${#DISABLE_DEVICES[@]} devices in <b>$i seconds</b>" \
		-u $NOTIFICATION_URGENCY \
		-t $__NOTIFICATION_COUNTDOWN_TIMEOUT \
		-c $NOTIFICATION_ICON_CATEGORY \
		-i $NOTIFICATION_ICON_NAME \
		-h int:value:$((100 * i / NOTIFICATION_COUNTDOWN)) \
		-h string:synchronous:disable-keyboard
	sleep 1
done

sudo "$0" release "${pids[@]}"

notify-send \
	"$NOTIFICATION_TITLE" \
	"<b><span size='$NOTIFICATION_TEXT_SIZE'>Enabled</span></b>\\n$device_count devices" \
	-u $NOTIFICATION_URGENCY \
	-t $NOTIFICATION_TIMEOUT \
	-c $NOTIFICATION_ICON_CATEGORY \
	-i $NOTIFICATION_ICON_NAME \
	-h string:synchronous:disable-keyboard
