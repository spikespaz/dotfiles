#! /usr/bin/env nix-shell
#! nix-shell -i bash -p home-manager
# shellcheck shell=bash

set -eu

# Default for my systems, each on a worktree branch in home.
: "${NIXOS_FLAKE_DIR:=$HOME/dotfiles.git/$(hostname)}"

verb=$1
noun=$2
shift 2

flakeRef=''
command=()

case "$noun" in
	nixos)
		flakeRef="path:$NIXOS_FLAKE_DIR#$(hostname)"
		command+=(sudo nixos-rebuild)
		;;
	home)
		flakeRef="path:$NIXOS_FLAKE_DIR#$(whoami)@$(hostname)"
		command+=(home-manager)
		;;
	*)
		echo 'Unknown noun. Must be one of: `nixos` or `home`.'
		exit 1
		;;
esac

case "$verb" in
	build)
		command+=(build)
		;;
	switch)
		command+=(switch)
		;;
	boot)
		command+=(boot)
		;;
	*)
		echo 'Unknown verb. Must be one of: `build`, `switch`, or `boot`.'
		exit 1
		;;
esac

set -x
"${command[@]}" --flake "$flakeRef" "$@"
set +x
