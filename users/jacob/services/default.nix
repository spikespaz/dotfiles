args@{ lib, config, ... }:
(lib.mapAttrs (_: expr: if lib.isFunction expr then expr args else expr)
  (lib.importDir ./. "default.nix")) // {
    udiskie = {
      # service that auto-mounts storage devices with udisks2
      services.udiskie = {
        enable = true;
        automount = true;
        notify = true;
        tray = "auto";
        # <https://github.com/coldfix/udiskie/blob/master/doc/udiskie.8.txt#configuration>
        # settings = {}
      };
    };

    playerctl = {
      services.playerctld.enable = true;
      home.packages = [ config.services.playerctld.package ];
    };

    keepassxc = { services.keepassxc.enable = true; };

    steam = { services.steam.enable = true; };

    thunderbird = {
      systemd.user.services.thunderbird = {
        Unit = {
          Description = "Thunderbird";
          After = [ "network.target" "graphical-session.target" ];
          StartLimitIntervalSec = 300;
          StartLimitBurst = 5;
        };
        Service = {
          Type = "simple";
          ExecStart = lib.getExe config.programs.thunderbird.package;
          Restart = "always";
          RestartSec = "1s";
        };
        Install = { WantedBy = [ "graphical-session.target" ]; };
      };
    };
  }
