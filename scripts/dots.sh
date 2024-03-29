#! /usr/bin/env nix-shell
#! nix-shell -i bash -p home-manager
# shellcheck shell=bash
# shellcheck disable=SC2016

# We assume that the `nixos-rebuild` command is already present,
# since this script is intended for NixOS.

set -eu -o pipefail

if [[ "${NIXOS_FLAKE_IS_WORKTREE:=0}" -eq 1 ]]; then
	: "${NIXOS_FLAKE_BASENAME:=dotfiles.git}"
else
	: "${NIXOS_FLAKE_BASENAME:=dotfiles}"
fi

: "${NIXOS_FLAKE_HOST_BRANCHES:=1}"
if [[ "$NIXOS_FLAKE_HOST_BRANCHES" -eq 1 ]]; then
	: "${NIXOS_FLAKE_WORKTREE_BRANCH:=$(hostname)}"
else
	: "${NIXOS_FLAKE_WORKTREE_BRANCH:=master}"
fi

if [[ -z "${NIXOS_FLAKE_DIR:-}" ]]; then
	: "${NIXOS_FLAKE_DIR:="$HOME/$NIXOS_FLAKE_BASENAME"}"
	if [[ "$NIXOS_FLAKE_IS_WORKTREE" -eq 1 ]]; then
		NIXOS_FLAKE_DIR+="/$NIXOS_FLAKE_WORKTREE_BRANCH"
	fi
fi

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
		case "$verb" in
			build)
				command+=(nixos-rebuild build)
				;;
			switch)
				command+=(sudo nixos-rebuild switch)
				;;
			boot)
				command+=(sudo nixos-rebuild boot)
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
		case "$verb" in
			build)
				command+=(home-manager build)
				;;
			switch)
				command+=(home-manager switch)
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
