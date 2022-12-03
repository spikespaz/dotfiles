#! /usr/bin/env bash
set -eux

toggle_script="$(realpath "$(dirname "$0")")/disable-devices.sh"

prefix=()
if [ -n "${DISABLE_DEVICES-}" ]; then
	prefix=("DISABLE_DEVICES='$DISABLE_DEVICES'")
fi

: "${DISABLE_DELAY:=1}"
: "${DISABLE_DURATION:=30}"
: "${NOTIFICATION_COUNTDOWN:=28}"
: "${NOTIFICATION_TIMEOUT:=2000}"
: "${NOTIFICATION_TEXT_SIZE:=x-large}"
: "${NOTIFICATION_ICON_CATEGORY:=devices}"
: "${NOTIFICATION_ICON_NAME:=input-keyboard}"
: "${NOTIFICATION_URGENCY:=critical}"
: "${NOTIFICATION_TITLE:=Input/Keyboard}"
__NOTIFICATION_COUNTDOWN_TIMEOUT=2000

sleep "$(bc <<< "scale=3; $DISABLE_DELAY / 1000")"

IFS=' ' read -ra evtest_pids <<< "$(sudo "${prefix[@]}" "$toggle_script" disable)"
device_count=${#evtest_pids[@]}

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
		"Enabling $device_count devices in <b>$i seconds</b>" \
		-u $NOTIFICATION_URGENCY \
		-t $__NOTIFICATION_COUNTDOWN_TIMEOUT \
		-c $NOTIFICATION_ICON_CATEGORY \
		-i $NOTIFICATION_ICON_NAME \
		-h int:value:$((100 * i / NOTIFICATION_COUNTDOWN)) \
		-h string:synchronous:disable-keyboard
	sleep 1
done

sudo "${prefix[@]}" "$toggle_script" release

notify-send \
	"$NOTIFICATION_TITLE" \
	"<b><span size='$NOTIFICATION_TEXT_SIZE'>Enabled</span></b>\\n$device_count devices" \
	-u $NOTIFICATION_URGENCY \
	-t $NOTIFICATION_TIMEOUT \
	-c $NOTIFICATION_ICON_CATEGORY \
	-i $NOTIFICATION_ICON_NAME \
	-h string:synchronous:disable-keyboard
