#! /usr/bin/env nix-shell
#! nix-shell -i bash -p home-manager
# shellcheck shell=bash

set -eu -o pipefail

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
				echo 'Unknown verb paired with noun `nixos`, must be one of: `build`, `switch`, or `boot`.'
				;;
		esac
		command+=(--flake "$flakeRef" "$@")
		;;
	home)
		flakeRef="path:$NIXOS_FLAKE_DIR#$(whoami)@$(hostname)"
		command+=(home-manager)
		case "$verb" in
			build)
				command+=(build)
				;;
			switch)
				command+=(switch)
				;;
			*)
				echo 'Unknown verb paired with noun `home`, must be one of: `build`, or `switch`.'
				;;
		esac
		command+=(--flake "$flakeRef" "$@")
		;;
	*)
		echo 'Unknown noun. Must be one of: `nixos` or `home`.'
		exit 1
		;;
esac

echo "> ${command[*]}"
"${command[@]}"
