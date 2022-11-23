#! /usr/bin/env bash

set -eu

# DISABLE_DEVICES=(
# 	# AT Translated Set 2 Keyboard
# 	/dev/input/event0
# 	# Sleep Button
# 	/dev/input/event9
# 	# Power Button
# 	/dev/input/event10
# 	# Lid Switch
# 	/dev/input/event8
# 	# ThinkPad Extra Buttons
# 	/dev/input/event15
# 	# SynPS/2 Synaptics Touchpad
# 	/dev/input/event19
# 	# TPPS/2 Elan TrackPoint
# 	/dev/input/event21
# )

IFS=':' read -ra DISABLE_DEVICES <<< "$DISABLE_DEVICES"
device_count=${#DISABLE_DEVICES[@]}

: "${DISABLE_DURATION:=30}"
: "${NOTIFICATION_USER:="${SUDO_USER-$USER}"}"
: "${NOTIFICATION_COUNTDOWN:=28}"
: "${NOTIFICATION_TIMEOUT:=2000}"
: "${NOTIFICATION_TEXT_SIZE:=x-large}"
: "${NOTIFICATION_ICON_CATEGORY:=devices}"
: "${NOTIFICATION_ICON_NAME:=input-keyboard}"
: "${NOTIFICATION_URGENCY:=critical}"
: "${NOTIFICATION_TITLE:=Input/Keyboard}"

__NOTIFICATION_COUNTDOWN_TIMEOUT=2000

su "$NOTIFICATION_USER" -c "$(
cat <<- EOF
	notify-send \
		'$NOTIFICATION_TITLE' \
		"<b><span size='$NOTIFICATION_TEXT_SIZE'>Disabled</span></b>\\n${#DISABLE_DEVICES[@]} devices" \
		-u $NOTIFICATION_URGENCY \
		-t $NOTIFICATION_TIMEOUT \
		-c $NOTIFICATION_ICON_CATEGORY \
		-i $NOTIFICATION_ICON_NAME \
		-h string:synchronous:disable-keyboard
EOF
)"

pids=()

# for event in "${DISABLE_DEVICES[@]}"; do
# 	evtest --grab "$event" &> /dev/null &
# 	pids+=($!)
# done

sleep $((DISABLE_DURATION - NOTIFICATION_COUNTDOWN))

for i in $(seq 0 $NOTIFICATION_COUNTDOWN); do
	i=$((NOTIFICATION_COUNTDOWN - i))
	su "$NOTIFICATION_USER" -c "$(
	cat <<- EOF
		notify-send \
			'$NOTIFICATION_TITLE' \
			"Enabling ${#DISABLE_DEVICES[@]} devices in <b>$i seconds</b>" \
			-u $NOTIFICATION_URGENCY \
			-t $__NOTIFICATION_COUNTDOWN_TIMEOUT \
			-c $NOTIFICATION_ICON_CATEGORY \
			-i $NOTIFICATION_ICON_NAME \
			-h "int:value:$((100 * i / NOTIFICATION_COUNTDOWN))" \
			-h string:synchronous:disable-keyboard
	EOF
	)"
	sleep 1
done

# kill "${pids[@]}"

su "$NOTIFICATION_USER" -c "$(
cat <<- EOF
	notify-send \
		'$NOTIFICATION_TITLE' \
		"<b><span size='$NOTIFICATION_TEXT_SIZE'>Enabled</span></b>\\n${#DISABLE_DEVICES[@]} devices" \
		-u $NOTIFICATION_URGENCY \
		-t $NOTIFICATION_TIMEOUT \
		-c $NOTIFICATION_ICON_CATEGORY \
		-i $NOTIFICATION_ICON_NAME \
		-h string:synchronous:disable-keyboard
EOF
)"
