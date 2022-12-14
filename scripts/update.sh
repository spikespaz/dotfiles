#! /usr/bin/env bash
set -eu

nix () {
	/run/current-system/sw/bin/nix \
		--extra-experimental-features nix-command \
		--extra-experimental-features flakes \
		"$@"
}

flake_path=''
update_system=0
update_user=0
iso=0
host=$(hostname)
new_lockfile=0
use_overrides=0
action='switch'
user=''

fail () {
	cat <<- EOF
		Incorrect arguments, did you make a typo?

		Usage:
			$(basename "$0")
			[--flake <path>]
			[[-]s|[--]system]
			[[-]u|[--]user [<name>]]
			[-l|--lock]
			[--on-boot]
			[-o|--override-inputs]
			[-- <passthru>]

		'--flake <path>' specifies the path of the flake to build
		'-l' or '--lock' declares that a new lockfile should be created, renaming the old suffixed with a timestamp
		'--on-boot' sets the build action to 'boot' instead of 'switch'
		'-o' or '--override-inputs' will update the lockfile to use inputs from a directory named inputs in the root of the flake
	EOF
	exit 1
}

label () {
	border="####$(echo "$1" | sed 's/./#/g')####"
	printf "\n%s\n### $1 ###\n%s\n\n" "$border" "$border"
	unset border
}

while [ "$#" -gt 0 ]; do
	case $1 in
		--flake)
			flake_path="$2"
			shift 2
			;;
		-s|s|--system|system)
			update_system=1
			shift
			;;
		-u|u|--user|user)
			update_user=1
			if [ -n "${2-}" ] && [ -d "$flake_path/users/$2" ]; then
				user=$2
				shift
			fi
			shift
			;;
		-l|--lock)
			new_lockfile=1
			shift
			;;
		--on-boot)
			action='build'
			shift
			;;
		-o|--override-inputs)
			use_overrides=1
			shift
			;;
		--)
			shift
			break
			;;
		*)
			fail
			;;
	esac
done

if [ -z "$flake_path" ]; then
	here="$(realpath "$(dirname "$0")")"
	flake_path="$(git -C "$here" rev-parse --show-toplevel)"
fi

# if [ $update_system -ne 1 ] && [ $update_user -ne 1 ]; then
# 	fail
if [ $new_lockfile -eq 1 ] && [ -f "$flake_path/flake.lock" ]; then
	mv -f "$flake_path/flake.lock" "$flake_path/flake.lock.$(date +%s)"
fi

if [ $use_overrides -eq 1 ]; then
	label "OVERRIDE INPUTS"

	args=()

	for dir in "$flake_path"/inputs/*; do
		args+=(--override-input "$(basename "$dir")" "$dir")
	done

	nix flake lock "${args[@]}"
fi

if [ $update_system -eq 1 ]; then
	label "UPDATING SYSTEM"

	sudo -s <<- EOF
		# shellcheck disable=SC2068
		nixos-rebuild ${action} --flake 'path:$flake_path' $@
		chown $USER '$flake_path/flake.lock'
	EOF
fi

if [ $update_user -eq 1 ]; then
	if [ -z "$user" ]; then
		user="$USER"
	fi

	label "UPDATING USER: $user"

	module="homeConfigurations.$user.activationPackage"

	# shellcheck disable=SC2068
	nix build --no-link "path:$flake_path#$module" $@

	# seems that the file isn't immediately guaranteed or immediately available?
	# sleep 0.5
	# no, that doesn't work.

	if [ "$action" == 'switch' ]; then
		result="$(nix path-info "path:$flake_path#$module")"
		"$result/activate"
	fi
fi
