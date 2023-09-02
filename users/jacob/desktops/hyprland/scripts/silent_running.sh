#!/usr/bin/env bash
set -eu

script_name="$(basename "$0" | cut -d. -f1)"

: "${LOCK_FILE_DIR:="/var/run/user/$(id -u)/scripts/${script_name}"}"
mkdir -p "$LOCK_FILE_DIR"

: "${SCREEN_OFF_DELAY:=5}"

lock_file="$LOCK_FILE_DIR/${script_name}.lock"

if [ ! -f "$lock_file" ]; then
	touch "$lock_file"

	hyprctl -j getoption 'misc:mouse_move_enables_dpms' | jq '.int' \
		> "$LOCK_FILE_DIR"/mouse_move_enables_dpms.state
	hyprctl -j getoption 'misc:key_press_enables_dpms' | jq '.int' \
		> "$LOCK_FILE_DIR"/key_press_enables_dpms.state

	hyprctl keyword 'misc:mouse_move_enables_dpms' 0
	hyprctl keyword 'misc:key_press_enables_dpms' 0

	loginctl lock-session
	sleep "$SCREEN_OFF_DELAY"
	hyprctl dispatch dpms off
else
	hyprctl dispatch dpms on

	read -r mouse_move_enables_dpms < "$LOCK_FILE_DIR/mouse_move_enables_dpms.state"
	read -r key_press_enables_dpms < "$LOCK_FILE_DIR/key_press_enables_dpms.state"

	hyprctl keyword 'misc:mouse_move_enables_dpms' "$mouse_move_enables_dpms"
	hyprctl keyword 'misc:key_press_enables_dpms' "$key_press_enables_dpms"

	rm "$lock_file" "$LOCK_FILE_DIR"/*.state
fi

# FIXME
# `SCREEN_OFF_DELAY` is intended to be session locker grace-time,
#	but input events that cancel the lock screen are not handled.
# If, for exmaple, the cursor is moved during that interval, the
# lock screen will go away but the screen is still turned off.

# FIXME
# Input is still recieved in this mode. That means the system is hackable,
# if someone knows the right thing to type and can do it blind.
