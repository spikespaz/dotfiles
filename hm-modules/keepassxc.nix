{ config, lib, pkgs, ... }:
let
  inherit (lib) types;
  cfg = config.programs.keepassxc;
in {
  options = {
    programs.keepassxc = {
      enable = lib.mkEnableOption (lib.mdDoc ''
        Whether to install KeePassXC.
      '');

      package = lib.mkPackageOption pkgs "keepassxc" { };

      systemd = lib.mkEnableOption (lib.mdDoc ''
        Whether to enable the systemd service to start
        KeePassXC as a daemon (useful for browser integration)
        on the start of a graphical session.
      '');
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    { home.packages = [ cfg.package ]; }

    (lib.mkIf cfg.systemd {
      systemd.user.services.keepassxc = {
        Unit = {
          Description = cfg.package.meta.description;
          After = [ "graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          KillMode = "process";
          ExecStart = lib.getExe cfg.package;
          Restart = "on-failure";
          RestartSec = 5;
        };
        Install = { WantedBy = [ "graphical-session.target" ]; };
      };
    })
  ]);
}
