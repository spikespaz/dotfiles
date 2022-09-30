#! /bin/sh
set -eu

here="$(realpath "$(dirname "$0")")"

fail () {
	echo
	echo 'Incorrect arguments, did you make a typo?'
	echo
	echo "Usage: $(basename "$0") [[-]s|[--]system] [[-]u|[--]user [<name>]] [-l|--lock]"
	echo "The '--lock' option renames '$here/flake.lock', take care!"
	echo
	exit 1
}

label () {
	border="####$(echo "$1" | sed 's/./#/g')####"
	printf "\n%s\n### $1 ###\n%s\n\n" "$border" "$border"
	unset border
}

update_system=0
update_user=0
new_lockfile=0
user=''

while [ $# -gt 0 ]; do
	case $1 in
		-s|s|--system|system)
			update_system=1
			shift
			;;
		-u|u|--user|user)
			update_user=1
			if [ -n "$2" ] && [ -d "$here/users/$2" ]; then
				user=$2
				shift
			fi
			shift
			;;
		-l|--lock)
			new_lockfile=1
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

if [ $update_system -ne 1 ] && [ $update_user -ne 1 ]; then
	fail
elif [ $new_lockfile -eq 1 ] && [ -f "$here/flake.lock" ]; then
	mv -f "$here/flake.lock" "$here/flake.lock.$(date +%s)"
fi

if [ $update_system -eq 1 ]; then
	label "UPDATING SYSTEM"

	sudo -s <<-EOF
		# shellcheck disable=SC2068
		nixos-rebuild switch --flake "path:$here" $@
		chown $USER "$here/flake.lock"
	EOF
fi

if [ $update_user -eq 1 ]; then
	if [ -z "$user" ]; then
		user="$USER"
	fi

	label "UPDATING USER: $user"

	module="path:$here#homeConfigurations.$user.activationPackage"

	# shellcheck disable=SC2068
	nix build --no-link "$module" $@
	"$(nix path-info "$module")/activate"
fi
