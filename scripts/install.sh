#! /usr/bin/env bash
set -eu

nix () {
	/run/current-system/sw/bin/nix \
		--extra-experimental-features nix-command \
		--extra-experimental-features flakes \
		"$@"
}

flake_path=''
host_name="$(hostname)"
root_dir='/mnt'
# unstable=1
passthru=()

if [ "$#" -eq 1 ]; then
	host_name="$1"
	shift
elif [ "$#" -gt 1 ]; then
	while [ "$#" -gt 0 ]; do
		case "$1" in
			--flake)
				flake_path="$2"
				shift 2
				;;
			-h|--host)
				host_name="$2"
				shift 2
				;;
			-r|--root)
				root_dir="$2"
				shift 2
				;;
			--)
				shift
				passthru=($@)
				break
				;;
			*)
				echo "Unrecognized option $1"
				exit 1
				;;
		esac
	done
# else
# 	echo 'Requires at least one argument, the name of the attribute in #nixosConfigurations to build.'
fi

here="$(realpath "$(dirname "$0")")"

if [ -z "$flake_path" ]; then
	flake_path="$(git -C "$here" rev-parse --show-toplevel)"
fi

nixos-install \
	--root "$root_dir" \
	--flake "path:$flake_path#$host_name" \
	--no-root-password \
	"${passthru[@]}"
