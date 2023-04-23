args @ {
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) types;
  cfg = config.wayland.windowManager.hyprland;
  cfgPath = "config.wayland.windowManager.hyprland";

  configFormat = (import ./configFormat.nix args) {
    # renames = import ./renames.nix;
  };
in {
  options = {
    wayland.windowManager.hyprland = {
      enableConfig = lib.mkEnableOption (lib.mdDoc ''
        Enable writing the Hyprland configuration file.

        `~/.config/hypr/hyprland.conf`
      '');

      # This replaces `wayland.windowManager.hyprland.extraConfig`.
      configLines = lib.mkOption {
        type = types.lines;
        description = lib.mdDoc ''
          Lines of the hyprland config to write.
        '';
      };

      reloadConfig = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = lib.mdDoc ''
          If enabled, automatically tell Hyprland to reload configuration
          after activating a new Home Manager generation.

          Note, this option is different from
          `${cfgPath}.config.misc.disable_autoreload`,
          which disables Hyprland's filesystem watch.
        '';
      };

      ### CONFIG ###

      extraInitConfig = lib.mkOption {
        type = configFormat.type;
        default = null;
        description = lib.mdDoc ''
          Extra configuration to be prepended to the top of
          `~/.config/hypr/hyprland.conf` (after module's generated init).
        '';
        # example = lib.literalExpression "";
      };

      config = lib.mkOption {
        type = configFormat.type;
        default = {};
        description = lib.mdDoc ''
          Hyprland config attributes.
          These will be serialized to lines of text,
          included in `configLines`.
        '';
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.systemdIntegration {
      wayland.windowManager.hyprland.configLines = lib.mkOrder 1 ''
        exec-once=${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP
        exec-once=systemctl --user start hyprland-session.target
      '';
    })
    (lib.mkIf (cfg.extraInitConfig != null) {
      wayland.windowManager.hyprland.configLines =
        lib.mkOrder 50 (configFormat.toConfigString cfg.extraInitConfig);
    })
    (lib.mkIf (cfg.config != null) {
      wayland.windowManager.hyprland.configLines =
        lib.mkOrder 350 (configFormat.toConfigString cfg.config);
    })
    (lib.mkIf (cfg.extraConfig != null) {
      wayland.windowManager.hyprland.configLines =
        lib.mkOrder 900 cfg.extraConfig;
    })
    (lib.mkIf cfg.enableConfig {
      # Create the config file with content from `configLines`.
      # This replaces `wayland.windowManager.hyprland.extraConfig`.
      xdg.configFile."hypr/hyprland.conf" = lib.mkForce {
        text = cfg.configLines;
        onChange = lib.mkIf (cfg.reloadConfig) ''
          (
            shopt -s nullglob
            for socket in /tmp/hypr/_*/.socket.sock; do
              response="$(
                printf 'reload config-only' \
                  | ${pkgs.netcat}/bin/nc -U $socket 2>/dev/null || true
              )"
              if [[ "$response" == 'ok' ]]; then
                instance="$(egrep -o '_[0-9]+' <<< $socket)"
                echo "Reloading Hyprland instance $instance"
              fi
            done
          )
        '';
      };
    })
  ];
}
