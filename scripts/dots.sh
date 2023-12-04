#! /usr/bin/env nix-shell
#! nix-shell -i bash -p home-manager
# shellcheck shell=bash

set -eu -o pipefail

# Default for my systems, each on a worktree branch in home.
: "${NIXOS_FLAKE_DIR:=$HOME/dotfiles.git/$(hostname)}"

if [[ ! -e "$NIXOS_FLAKE_DIR/.git" ]]; then
	echo "NIXOS_FLAKE_DIR is set to \`$NIXOS_FLAKE_DIR\` but that path doesn't exist or is not a git repository."
	exit 1
fi

verb=$1
noun=$2
shift 2

flakeRef=''
command=()

case "$noun" in
	host)
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
				echo 'Unknown verb paired with noun `host`, must be one of: `build`, `switch`, or `boot`.'
				exit 1
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
				exit 1
				;;
		esac
		command+=(--flake "$flakeRef" "$@")
		;;
	*)
		echo 'Unknown noun. Must be one of: `host` or `home`.'
		exit 1
		;;
esac

echo "> ${command[*]}"
"${command[@]}"
