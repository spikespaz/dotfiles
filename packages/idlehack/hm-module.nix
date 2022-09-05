self: { config, lib, pkgs, ... }: let
  cfg = config.services.idlehack;
  pkg = self.packages.${pkgs.system}.idlehack;
in {
  options = {
    services.idlehack.enable = lib.mkEnableOption pkg.meta.description;
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.idlehack = {
      Unit = {
        Description = pkg.meta.description;
        After = [ "syslog.target" ];
      };
      Service = {
        Type = "simple";
        KillMode = "process";
        Environment = "PATH=${lib.makeBinPath [ pkgs.systemd pkg ]}";
        ExecStart = lib.getExe pkg;
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
