#!/usr/bin/env bash
set -eu

# If the window is not floating, make it so.
if hyprctl -j activewindow | jq -e '.floating == false'; then
	hyprctl dispatch togglefloating active;
fi

# This is a toggle.
hyprctl dispatch pin active
