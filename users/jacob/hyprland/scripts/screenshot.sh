#! /usr/bin/env nix-shell
#! nix-shell -i bash -p jq hyprland grim wl-clipboard
# shellcheck shell=bash

set -eu -o pipefail

declare -A window
while IFS='=' read -r key value; do
  window["$key"]="$value"
done < <(
	hyprctl -j activewindow \
	| jq -r '{x: .at[0], y: .at[1], w: .size[0], h: .size[1], title: .initialTitle} | to_entries | .[] | "\(.key)=\(.value)"'
)

echo "title: ${window['title']}"
echo "x: ${window['x']}"
echo "y: ${window['y']}"
echo "w: ${window['w']}"
echo "h: ${window['h']}"

time_date="$(date '+%Y-%m-%d_%H:%M:%S')"

title="${window['title']}"
title="${title//\'/}"
title="${title//[[:space:]]/_}"
title="${title//[^a-zA-Z0-9]/-}"

image_name="${title}_$time_date.png"
image_path="/tmp/$image_name"

echo "image path: $image_path"

grim \
	-c \
	-t png \
	-g "${window["x"]},${window["y"]} ${window["w"]}x${window["h"]}" \
	"$image_path"

wl-copy -t image/png < "$image_path"
