#! /bin/sh
set -eu

interval="$1"
chance="$2"
img_dir="$3"

if [ "$interval" -ne "$interval" ]; then
  echo 'Error: argument 1 was not a number!'
  exit 10
fi
if [ "$chance" -ne "$chance" ]; then
  echo 'Error: argument 2 was not a number!'
  exit 11
fi
if [ ! -d "$img_dir" ]; then
  echo 'Error: argument 3 was not a directory!'
  exit 12
fi

echo "(\$1) Interval = $interval"
echo "(\$2) Chance = $chance"
echo "(\$3) Image Directory = $img_dir"
echo "User = $USER"

set_img() {
  old_pids="$(pgrep -U "$USER" -x 'swaybg' || :)"
  if [ -z "$old_pids" ]; then
    echo "Found old swaybg PIDs: $old_pids"
  fi

  echo 'Selecting new image...'
  new_img="$(
    find "$img_dir" \
      -type f \
      -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \
      | shuf -n1
  )"
  if [ ! -f "$new_img" ]; then
    echo 'Error: could not find the next image!'
    exit 20
  fi
  echo "Selected new image: $new_img"

  if [ "$new_img" = "${old_img-}" ]; then
    echo 'Duplicate, re-rolling...'
    set_img
  else
    echo 'Setting the selected image...'
    swaybg -i "$new_img" -m fill &

    if [ -n "${old_pids-}" ]; then
      sleep 10 # this is huge because of huge images
      echo 'Killing old swaybg PIDs...'
      # shellcheck disable=SC2086
      kill -s 9 $old_pids
    fi

    old_img="$new_img"
  fi
}

echo 'Setting the first image!'
set_img
if [ -n "${NOTIFY_SOCKET-}" ]; then
  systemd-notify --ready
  ## systemd-notify always returns nonzero, but the message is sent anyway
  # if [ "$(systemd-notify --ready)" ]; then
  #   echo "Notified systemd that this unit is ready."
  # else
  #   echo 'Error: failed to notify systemd that we are ready!'
  #   exit 30
  # fi
fi
sleep "$interval"

while true; do
  echo 'Deciding if the wallpaper should be changed...'
  if [ "$(shuf -i0-100 -n1)" -le "$chance" ]; then
    echo 'Lucky roll, resetting!'
    set_img
  else
    echo 'Entropy rejects you.'
  fi

  echo 'Finished, waiting for next loop...'
  sleep "$interval"
done
