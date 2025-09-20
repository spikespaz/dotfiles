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

flakeRef=''
command=()

function build() {
	case "$1" in
		host)
			shift
			flakeRef="path:$NIXOS_FLAKE_DIR#nixosConfigurations.$(hostname).config.system.build.toplevel"
			command=(nix build "$flakeRef" "$@")
			# command=(nixos-rebuild build --flake "$flakeRef" "$@")
			;;
		home)
			shift
			flakeRef="path:$NIXOS_FLAKE_DIR#homeConfigurations.$(whoami)@$(hostname).activationPackage"
			command=(nix build "$flakeRef" "$@")
			# command=(home-manager build --flake "$flakeRef" "$@")
			;;
		*)
			echo 'Unknown noun '"'$1'"' for verb `build`, must be one of: `host`, `home`.'
			exit 1
			;;
	esac
}

function switch() {
	case "$1" in
		host)
			shift
			flakeRef="path:$NIXOS_FLAKE_DIR#$(hostname)"
			command=(sudo nixos-rebuild switch --flake "$flakeRef" "$@")
			;;
		home)
			shift
			flakeRef="path:$NIXOS_FLAKE_DIR#$(whoami)@$(hostname)"
			command=(home-manager switch --flake "$flakeRef" "$@")
			;;
		*)
			echo 'Unknown noun '"'$1'"' for verb `switch`, must be one of: `host`, `home`.'
			exit 1
			;;
	esac
}

function boot() {
	case "$1" in
		host)
			shift
			flakeRef="path:$NIXOS_FLAKE_DIR#$(hostname)"
			command=(sudo nixos-rebuild boot --flake "$flakeRef" "$@")
			;;
		*)
			echo 'Unknown noun '"'$1'"' for verb `boot`, must be one of: `host`.'
			exit 1
			;;
	esac
}

verb=$1
shift

case "$verb" in
	build)
		build "$@"
		;;
	switch)
		switch "$@"
		;;
	boot)
		boot "$@"
		;;
	*)
		echo 'Unknown verb '"'$verb'"', must be one of `build`, `switch` or `boot`.'
		exit 1
		;;
esac

echo "> ${command[*]}"
"${command[@]}"
