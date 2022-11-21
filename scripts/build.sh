#! /usr/bin/env bash
set -eu

flake_path=''
store_root='/'
build_host=''
build_user=''
nix_passthru=()
build_passthru=()

nix () {
	/run/current-system/sw/bin/nix \
		--extra-experimental-features nix-command \
		--extra-experimental-features flakes \
		"$@"
}

flake_has_host () {
    return [ -d "$flake_path/systems/$1" ] \
        || [ -f "$flake_path/systems/$1.nix" ]
}

flake_has_user () {
    return [ -d "$flake_path/users/$1" ] \
        || [ -f "$flake_path/users/$1.nix" ]
}

while [ "$#" -ne 0 ]; do
    case "$1" in
        -f|--flake)
            flake_path="$2"
            shift 2
            ;;
        -s|--store)
            store_root="$2"
            shift 2
            ;;
        -h|--host-name)
            if [ -n "${2-}" ] && flake_has_host "${2-!}"; then
                build_host="$2"
                shift 1
            elif flake_has_host "$(hostname)"; then
                build_host="$(hostname)"
            else
                echo "No host specified and '$(hostname)' is not an output."
                exit 12
            fi
            shift 1
            ;;
        -u|--user-name)
            if [ -n "${2-}" ] && flake_has_user "${2-!}"; then
                build_user="$2"
                shift 1
            elif flake_has_user "$USER"; then
                build_user="$USER"
            else
                echo "No user specified and '$USER' is not an output."
                exit 12
            fi
            shift 1
            ;;
        --show-trace)
            nix_passthru+=("--show-trace")
            shift
            ;;
        --)
            shift
            build_passthru=("$@")
            break
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
    esac
done

if [ -z "$build_host" ] && [ -z "$build_user" ]; then
    echo "You must specify what to build!"
    exit 10
fi

if [ -z "$flake_path" ]; then
	here="$(realpath "$(dirname "$0")")"
	flake_path="$(git -C "$here" rev-parse --show-toplevel)"
fi

if [ -n "$build_host" ]; then
    module="nixosConfigurations.$build_host.config.system.build.toplevel"
elif [ -n "$build_user" ]; then
    module="homeConfigurations.$build_user.activationPackage"
fi

nix "${nix_passthru[@]}" build \
        --no-link \
        --store "$store_root" \
        "path:$flake_path#$module" \
        "${build_passthru[@]}"
