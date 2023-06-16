{ lib, pkgs, ... }:
let
  runGameScriptBin = pkgs.writeShellScriptBin "run-game" ''
    set -eu
    if [ "$(id -u)" -eq 0 ]; then
      ${pkgs.util-linux}/bin/renice -n -19 -p "$1"
    else
      set -m
      "$@" &
      pid=$!
      /run/wrappers/bin/sudo "$0" $pid
      fg 1
    fi
  '';
in {
  environment.systemPackages = [ runGameScriptBin ];

  security.sudo.extraRules = [{
    users = [ "jacob" ];
    commands = [{
      command = lib.getExe runGameScriptBin;
      options = [ "NOPASSWD" ];
    }];
  }];

  programs.steam = {
    enable = true;
    # Open ports in the firewall for Steam Remote Play
    remotePlay.openFirewall = true;
    # Open ports in the firewall for Source Dedicated Server
    dedicatedServer.openFirewall = true;
  };
}
