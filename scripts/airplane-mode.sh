#! /usr/bin/env bash

set -x

if [[ $UID -ne 0 ]]; then
  sudo "$0" "$@"
  exit $?
fi

if [[ "$1" = toggle ]]; then
  if [[ ! -f /var/lib/airplane-mode.state ]]; then
    echo 0 > /var/lib/airplane-mode.state
    state=0
  else
    state=$(cat /var/lib/airplane-mode.state)
    "$0" $(($state == 1 ? 0 : 1))
  fi
elif [[ "$1" -eq 1 ]]; then
  systemctl stop iwd.service
  systemctl stop bluetooth.service
  rfkill block all
  echo 1 > /var/lib/airplane-mode.state
elif [[ "$1" -eq 0 ]]; then
  rfkill unblock all
  systemctl restart iwd.service
  systemctl restart bluetooth.service
  echo 0 > /var/lib/airplane-mode.state
else
  echo 'missing arg: 0 for off, 1 for on, or toggle'
fi
