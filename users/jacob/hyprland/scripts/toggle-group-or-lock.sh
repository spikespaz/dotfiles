#! /usr/bin/env bash
set -euo pipefail

activewindow="$(hyprctl -j activewindow)"
grouped_count="$(echo "$activewindow" | jq '.grouped | length')"

if [[ $grouped_count -lt 2 ]]; then
	hyprctl dispatch togglegroup
else
	hyprctl dispatch lockactivegroup toggle
fi
