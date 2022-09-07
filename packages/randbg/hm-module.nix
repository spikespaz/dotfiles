self: { config, lib, pkgs, ... }: let
  description = "Customizable wallpaper randomization service";
  cfg = config.services.randbg;
in {
  options = {
    services.randbg = {
      enable = lib.mkEnableOption description;

      directory = lib.mkOption {
        type = lib.types.str;
        default = "${config.home.homeDirectory}/Pictures/Wallpapers";
        defaultText = lib.literalExpression ''
          ${config.home.homeDirectory}/Pictures/Wallpapers
        '';
        description = ''
          The path to the directory where your desired wallpapers are stored.
          This directory will be recursed when selecting new images, and
          valid extensions are `*.png`, `*.jpg`, and `*.jpeg`.
        '';
      };
      
      interval = lib.mkOption {
        type = lib.types.ints.positive;
        default = 30 * 60;
        defaultText = lib.mdDoc "`30 * 60` seconds";
        description = ''
          The time interval between wallpaper cycles, in seconds.
        '';
      };

      chance = lib.mkOption {
        type = lib.types.ints.between 1 100;
        default = 25;
        defaultText = lib.mdDoc "`25` percent chance";
        description = ''
          The percentage chance that the wallpaper will change
          after each interval.
        '';
      };

      wantedBy = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "hyprland-session.target" ];
        defaultText = lib.literalExpression ''
          [ "hyprland-session.target" ]
        '';
        description = ''
          The value of `Install.WantedBy` in the generated *systemd*
          service unit. Use this option to make your window manager's
          target unit trigger this service when it starts.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.random-wallpaper = {
      Unit = {
        Description = description;
        PartOf = "graphical-session.target";
      };
      Service = {
        Type = "notify";
        NotifyAccess = "all";  # because of a bug?
        Environment = ''
          PATH=${with pkgs; lib.makeBinPath [
            systemd coreutils procps findutils swaybg
          ]}
        '';
        ExecStart = ''
          ${./wallpaper.sh} \
            ${toString cfg.interval} ${toString cfg.chance} '${cfg.directory}'
        '';
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = cfg.wantedBy;
    };
  };
}
