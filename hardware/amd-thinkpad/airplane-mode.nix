{ lib, pkgs, ... }:
let
  # The hardware already gets soft-blocked, but I want a button to restart the driver if it acts up.
  # I will bind this to SHIFT + XF86WLAN.
  airplane-mode = pkgs.writeShellScriptBin "airplane-mode" ''
    set -x
    if [[ "$1" -eq toggle ]]; then
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
      modprobe -r ath11k
      modprobe -r bluetooth
      sudo echo 1 > /var/lib/airplane-mode.state
    elif [[ "$1" -eq 0 ]]; then
      modprobe ath11k
      modprobe bluetooth
      rfkill unblock all
      systemctl start iwd.service
      systemctl start bluetooth.service
      sudo echo 0 > /var/lib/airplane-mode.state
    else
      echo 'missing arg: 0 for off, 1 for on, or toggle'
    fi
  '';
in {
  environment.systemPackages = [ airplane-mode ];

  security.sudo.extraRules = [{
    groups = [ "users" ];
    commands = [{
      command = lib.getExe airplane-mode;
      options = [ "NOPASSWD" ];
    }];
  }];
}
