#! /usr/bin/env nix-shell
#! nix-shell -i bash -p jq hyprland grim wl-clipboard
# shellcheck shell=bash

set -eu -o pipefail

declare -A bounds
while IFS='=' read -r key value; do
  bounds["$key"]="$value"
done < <(
	hyprctl -j activewindow \
	| jq -r '{x: .at[0], y: .at[1], w: .size[0], h: .size[1]} | to_entries | .[] | "\(.key)=\(.value)"'
)

echo "x: ${bounds["x"]}"
echo "y: ${bounds["y"]}"
echo "w: ${bounds["w"]}"
echo "h: ${bounds["h"]}"

grim \
	-c \
	-t png \
	-g "${bounds["x"]},${bounds["y"]} ${bounds["w"]}x${bounds["h"]}" \
	- | wl-copy -t image/png

