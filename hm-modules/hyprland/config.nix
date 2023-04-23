args @ {
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) types;
  cfg = config.wayland.windowManager.hyprland;
  cfgPath = "config.wayland.windowManager.hyprland";

  indexOf = x: default: xs: lib.pipe xs [
    (lib.imap0 (i: v: if v == x then i else null))
    (lib.findFirst (x: x != null) default)
  ];

  configFormat = (import ./configFormat.nix args) {
    indentChars = "    ";
    sortPred = a: b: let
      ia = indexOf a 0 cfg.configOrder;
      ib = indexOf b 0 cfg.configOrder;
    in
      ia < ib;
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

      configOrder = lib.mkOption {
        type = types.listOf (types.listOf types.singleLineStr);
        default = [
          ["animations" "bezier"]
          ["animations" "animation"]
        ];
        description = lib.mdDoc ''
          An ordered list of attribute paths
          to determine sorting order of config section lines.

          This is necessary in some cases, namely where `bezier` must be defined
          before it can be used in `animation`.
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
