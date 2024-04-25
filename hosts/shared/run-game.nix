{ self, lib, pkgs, ... }:
let
  run-game = pkgs.patchShellScript "${self}/scripts/run-game.sh" rec {
    name = "run-game";
    destination = "/bin/${name}";
    runtimeInputs = [ pkgs.util-linux ];
  };
in {
  environment.systemPackages = [ run-game ];

  security.sudo.extraRules = [{
    users = [ "jacob" ];
    commands = [{
      command = lib.getExe run-game;
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
