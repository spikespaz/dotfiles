{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) types;
  cfg = config.wayland.windowManager.hyprland // config.wayland.windowManager.hyprland.alt;
  cfgPath = "config.wayland.windowManager.hyprland.alt";
in {
  options = {
    wayland.windowManager.hyprland.alt = {
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
        type = types.nullOr types.lines;
        default = null;
        description = lib.mdDoc ''
          Extra configuration to be prepended to the top of
          `~/.config/hypr/hyprland.conf` (after module's generated init).
        '';
        # example = lib.literalExpression "";
      };

      extraConfig = lib.mkOption {
        type = types.nullOr types.lines;
        default = null;
        description = lib.mdDoc ''
          Extra configuration lines to append to the bottom of
          `~/.config/hypr/hyprland.conf`.
        '';
      };

      config = lib.mkOption {
        type = types.attrs;
        default = {};
        description = lib.mdDoc ''
          Hyprland config attributes.
          These will be serialized to lines of text,
          included in `configLines`.
        '';
      };
    };
  };

  config = let
    indent = chars: level: lib.concatStrings (map (_: chars) (lib.range 1 level));
    indent' = indent "    ";
    configSection = level: attrs: let
      lines = lib.filterAttrs (_: v: !(lib.isAttrs v)) attrs;
      sections = lib.filterAttrs (_: lib.isAttrs) attrs;
    in
      lib.concatStrings (
        # Top level config attributes
        (lib.mapAttrsToList (
            name: value: "\n${indent' level}${name} = ${valueToString value}"
          )
          lines)
        # Then the sections
        ++ (lib.mapAttrsToList (
            name: value: "\n${indent' level}${name} {${configSection (level + 1) value}\n${indent' level}}"
          )
          sections)
      );
    valueToString = value:
      if lib.isBool value
      then lib.boolToString value
      else if lib.isInt value || lib.isFloat value
      then toString value
      else if lib.isString value
      then value
      else if lib.isList value
      then lib.concatMapStringsSep " " valueToString value
      else abort (lib.traceSeqN 2 value "Invalid value, cannot convert '${builtins.typeOf value}' to Hyprland config string value");
  in
    lib.mkMerge [
      (lib.mkIf (cfg.extraInitConfig != null) {
        wayland.windowManager.hyprland.alt.configLines = lib.mkOrder 0 cfg.extraInitConfig;
      })
      (lib.mkIf cfg.systemdIntegration {
        wayland.windowManager.hyprland.alt.configLines = lib.mkOrder 50 ''
          exec-once=${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP
          exec-once=systemctl --user start hyprland-session.target
        '';
      })
      (lib.mkIf (cfg.config != null) {
        wayland.windowManager.hyprland.alt.configLines = lib.mkOrder 350 (configSection 0 cfg.config);
      })
      (lib.mkIf (cfg.extraConfig != null) {
        wayland.windowManager.hyprland.alt.configLines = lib.mkOrder 900 cfg.extraConfig;
      })
      (lib.mkIf cfg.enableConfig {
        # We do not want the original `onChange`
        wayland.windowManager.hyprland.disableAutoreload = true;

        # Create the config file with content from `configLines`.
        # This replaces `wayland.windowManager.hyprland.extraConfig`.
        xdg.configFile."hypr/hyprland.conf" = {
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
