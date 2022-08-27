#!/bin/sh
set -e

here="$(dirname $0)"

fail () {
  printf '\nIncorrect arguments, did you make a typo?\n'
  printf "Usage: $(basename $0) [[-]s|[--]system] [[-]u|[--]user [<name>]]\n"
  exit 1
}

label () {
  border="####$(sed 's/./#/g' <<< $1)####"
  printf "\n$border\n### $1 ###\n$border\n\n"
  unset border
}

update_system=0
update_user=0
user=''

while [ $# -gt 0 ]; do
  case $1 in
    -s|s|--system|system)
      update_system=1
      shift
      ;;
    -u|u|--user|user)
      update_user=1
      if [ ! -z $2 ] && [ -d "$here/users/$2" ]; then
        user=$2
        shift
      fi
      shift
      ;;
    *)
      fail
      ;;
  esac
done

if [ $update_system -ne 1 ] && [ $update_user -ne 1 ]; then
  fail
fi

if [ $update_system -eq 1 ]; then
  label "UPDATING SYSTEM"

  module="path:$here#"
  
  sudo nixos-rebuild switch --flake $module
fi

if [ $update_user -eq 1 ]; then
  if [ -z "$user" ]; then
    user="$USER"
  fi

  label "UPDATING USER: $user"

  module="path:$here#homeConfigurations.$user.activationPackage"

  nix build --no-link $module
  "$(nix path-info $module)/activate"
fi
