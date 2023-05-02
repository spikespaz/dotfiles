{ config, lib, pkgs, ... }:
let
  description = "Customizable wallpaper randomization service";
  cfg = config.services.randbg;
  inherit (lib) types;
in {
  options = {
    services.randbg = {
      enable = lib.mkEnableOption description;

      directory = lib.mkOption {
        type = types.str;
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
        type = types.ints.positive;
        default = 30 * 60;
        defaultText = lib.mdDoc "`30 * 60` seconds";
        description = ''
          The time interval between wallpaper cycles, in seconds.
        '';
      };

      chance = lib.mkOption {
        type = types.ints.between 1 100;
        default = 25;
        defaultText = lib.mdDoc "`25` percent chance";
        description = ''
          The percentage chance that the wallpaper will change
          after each interval.
        '';
      };

      swaybg.color = lib.mkOption {
        type = types.strMatching "^(#[a-fA-F0-9]{6})";
        default = "#121212";
        description = lib.mdDoc ''
          The RGBA color value to use as a background color (behind the mage).
        '';
      };

      swaybg.mode = lib.mkOption {
        type =
          types.enum [ "stretch" "fill" "fit" "center" "tile" "solid_color" ];
        default = "fit";
        description = lib.mdDoc ''
          The mode to use when fitting the image to the display.

          See `swaybg(1)` for more information.
        '';
      };

      wantedBy = lib.mkOption {
        type = types.listOf types.str;
        default = [ "sway-session.target" "hyprland-session.target" ];
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
        NotifyAccess = "all"; # because of a bug?
        ExecStart = lib.concatStringsSep " " [
          (lib.wrapShellScript pkgs ./wallpaper.sh
            (with pkgs; [ systemd coreutils procps findutils swaybg ]))
          "-i ${toString cfg.interval}"
          "-c ${toString cfg.chance}"
          "-d '${cfg.directory}'"
          "--"
          "-c ${cfg.swaybg.color}"
          "-m ${cfg.swaybg.mode}"
        ];
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = cfg.wantedBy;
    };
  };
}
