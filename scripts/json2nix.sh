#! /usr/bin/env bash
filename="$(basename "$0")-$(date +%s)-$(basename "$1")"
cat "$1" | sed -e 's;//.*$;;g' > /tmp/"$filename"
nix eval --expr 'builtins.fromJSON (builtins.readFile /tmp/'"$filename"')' --impure | nixfmt
