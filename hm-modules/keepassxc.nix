{ config, lib, pkgs, ... }:
let
  inherit (lib) types;
  service = config.services.keepassxc;
  program = config.programs.keepassxc;
in {
  options = {
    services.keepassxc = {
      enable = lib.mkEnableOption "KeePassXC Service";

      package = lib.mkOption {
        type = types.package;
        description = lib.mdDoc ''
          Uses the program configuration's package by default.
        '';
        defaultText = lib.mdDoc ''
          {option}`config.programs.keepassxc.package`
        '';
      };
    };

    programs.keepassxc = {
      enable = lib.mkEnableOption (lib.mdDoc ''
        Whether to install KeePassXC.
      '');

      package = lib.mkPackageOption pkgs "keepassxc" { };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf program.enable { home.packages = [ program.package ]; })

    { services.keepassxc.package = lib.mkDefault program.package; }

    (lib.mkIf service.enable {
      systemd.user.services.keepassxc = {
        Unit = {
          Description = program.package.meta.description;
          After = [ "graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          KillMode = "process";
          ExecStart = lib.getExe program.package;
          Restart = "on-failure";
          RestartSec = 5;
        };
        Install = { WantedBy = [ "graphical-session.target" ]; };
      };
    })
  ];
}
