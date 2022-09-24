{ self, ... }:
{ config, lib, pkgs, ... }:
let
  inherit (lib) types;
  cfg = config.services.idlehack;
in {
  options = {
    services.idlehack = {
      enable = lib.mkEnableOption cfg.package.meta.description;
      package = lib.mkOption {
        type = types.package;
        default = self.packages.${pkgs.system}.idlehack;
        example = lib.literalExpression ''
          pkgs.idlehack
        '';
        description = ''
          The package to use for the *idlehack* binary.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    systemd.user.services.idlehack = {
      Unit = {
        Description = cfg.package.meta.description;
        After = [ "syslog.target" ];
      };
      Service = {
        Type = "simple";
        KillMode = "process";
        Environment = "PATH=${lib.makeBinPath [ pkgs.systemd cfg.package ]}";
        ExecStart = lib.getExe cfg.package;
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
