# TODO maybe?
# <https://gist.github.com/dAnjou/b99f55de34b90246f381e71e3c8f9262>
# <https://github.com/keepassxreboot/keepassxc/issues/613>
{ config, lib, pkgs, ... }:
let
  inherit (lib) types;

  service = config.services.keepassxc;
  program = config.programs.keepassxc;

  iniFormat = pkgs.formats.ini { };
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

      settings = lib.mkOption {
        type = iniFormat.type;
        default = { };
        description = lib.mdDoc ''
          Settings to write in INI format to {file}`~/.config/keepassxc/keepassxc.ini`.
        '';
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf program.enable { home.packages = [ program.package ]; })

    { services.keepassxc.package = lib.mkDefault program.package; }

    (lib.mkIf (program.enable && program.settings != { }) {
      xdg.configFile."keepassxc/keepassxc.ini".source =
        iniFormat.generate "keepassxc.ini" program.settings;
    })

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
