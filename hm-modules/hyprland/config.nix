args@{ inputs, config, pkgs, lib, ... }:
let
  inherit (lib) types;

  cfg = config.wayland.windowManager.hyprland;
  cfgPath = "config.wayland.windowManager.hyprland";

  defaultPackage = inputs.hyprland.packages.${pkgs.system}.default.override {
    enableXWayland = cfg.xwayland.enable;
    hidpiXWayland = cfg.xwayland.hidpi;
    inherit (cfg) nvidiaPatches;
  };

  configRenames = import ./configRenames.nix args;
  configFormat = (import ./configFormat.nix args) {
    indentChars = "	";
    sortPred = a: b:
      let
        ia = indexOf a 0 cfg.configOrder;
        ib = indexOf b 0 cfg.configOrder;
      in ia < ib;
  };
  toConfigString = attrs:
    configFormat.toConfigString
    (with configRenames; renameAttrs renames.from renames.to attrs);

  indexOf = x: default: xs:
    lib.pipe xs [
      (lib.imap0 (i: v: if v == x then i else null))
      (lib.findFirst (x: x != null) default)
    ];
in {
  options = {
    wayland.windowManager.hyprland = {
      enable = lib.mkEnableOption (lib.mdDoc ''
        Whether to install the Hyprland package and generate configuration files.

        ${cfg.package.meta.description}

        See <${cfg.package.meta.homepage}> for more information.
      '');
      package = lib.mkOption {
        type = with lib.types; nullOr package;
        default = defaultPackage;
        defaultText = lib.literalExpression ''
          hyprland.packages.''${pkgs.stdenv.hostPlatform.system}.default.override {
            enableXWayland = config.wayland.windowManager.hyprland.xwayland.enable;
            hidpiXWayland = config.wayland.windowManager.hyprland.xwayland.hidpi;
            inherit (config.wayland.windowManager.hyprland) nvidiaPatches;
          }
        '';
        description = lib.mdDoc ''
          Hyprland package to use. Will override the 'xwayland' and
          'nvidiaPatches' options.

          Defaults to the one provided by the flake. Set it to
          {package}`pkgs.hyprland` to use the one provided by nixpkgs or
          if you have an overlay.

          Set to null to not add any Hyprland package to your path. This should
          be done if you want to use the NixOS module to install Hyprland.
        '';
      };

      systemdIntegration = lib.mkOption {
        type = types.bool;
        default = pkgs.stdenv.isLinux;
        description = lib.mdDoc ''
          Whether to enable {file}`hyprland-session.target` on
          hyprland startup. This links to {file}`graphical-session.target`.
          Some important environment variables will be imported to systemd
          and dbus user environment before reaching the target, including
          - {env}`DISPLAY`
          - {env}`HYPRLAND_INSTANCE_SIGNATURE`
          - {env}`WAYLAND_DISPLAY`
          - {env}`XDG_CURRENT_DESKTOP`
        '';
      };

      recommendedEnvironment = lib.mkEnableOption (lib.mdDoc ''
        Whether to set the recommended environment variables.
      '');

      xwayland.enable = lib.mkOption {
        type = types.bool;
        default = true;
        description = lib.mdDoc ''
          Enable XWayland.
        '';
      };

      xwayland.hidpi = lib.mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc ''
          Enable HiDPI XWayland.
        '';
      };

      nvidiaPatches = lib.mkOption {
        type = lib.types.bool;
        default = false;
        defaultText = lib.literalExpression "false";
        example = lib.literalExpression "true";
        description = lib.mdDoc ''
          Patch wlroots for better Nvidia support.
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

      config = lib.mkOption {
        type = configFormat.type;
        default = { };
        description = lib.mdDoc ''
          Hyprland config attributes.
          These will be serialized to lines of text,
          included in {path}`$XDG_CONFIG_HOME/hypr/hyprland.conf`.
        '';
      };

      extraConfig = lib.mkOption {
        type = types.nullOr types.lines;
        default = null;
        description = lib.mdDoc ''
          Extra configuration lines to append to the bottom of
          `~/.config/hypr/hyprland.conf`.
        '';
      };

      configOrder = lib.mkOption {
        type = types.listOf (types.listOf types.singleLineStr);
        default = [
          [ "exec-once" ]
          [ "exec" ]

          [ "monitor" ]
          [ "wsbind" ]

          [ "dwindle" ]
          [ "master" ]
          [ "general" ]
          [ "input" ]
          [ "binds" ]
          [ "gestures" ]
          [ "decoration" ]
          [ "animations" ]

          [ "blurls" ]
          [ "windowrulev2" ]

          [ "misc" ]
          [ "debug" ]

          [ "animations" "bezier" ]
          [ "animations" "animation" ]
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

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = lib.optional (cfg.package != null) cfg.package
        ++ lib.optional cfg.xwayland.enable pkgs.xwayland;

      home.sessionVariables =
        lib.mkIf cfg.recommendedEnvironment { NIXOS_OZONE_WL = "1"; };
    }
    (lib.mkIf cfg.systemdIntegration {
      systemd.user.targets.hyprland-session = {
        Unit = {
          Description = "hyprland compositor session";
          Documentation = [ "man:systemd.special(7)" ];
          BindsTo = [ "graphical-session.target" ];
          Wants = [ "graphical-session-pre.target" ];
          After = [ "graphical-session-pre.target" ];
        };
      };

      wayland.windowManager.hyprland.config.exec_once = [
        "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP"
        "systemctl --user start hyprland-session.target"
      ];
    })
    (lib.mkIf (cfg.config != null) {
      xdg.configFile."hypr/hyprland.conf".text =
        lib.mkOrder 500 (toConfigString cfg.config);
    })
    (lib.mkIf (cfg.extraConfig != null) {
      xdg.configFile."hypr/hyprland.conf".text =
        lib.mkOrder 900 cfg.extraConfig;
    })
    # (lib.mkIf cfg.enableConfig {
    #   xdg.configFile."hypr/hyprland.conf" = lib.mkForce {
    #     text = cfg.configLines;
    #     onChange = lib.mkIf (cfg.reloadConfig) ''
    #       (
    #         shopt -s nullglob
    #         for socket in /tmp/hypr/_*/.socket.sock; do
    #           response="$(
    #             printf 'reload config-only' \
    #               | ${pkgs.netcat}/bin/nc -U $socket 2>/dev/null || true
    #           )"
    #           if [[ "$response" == 'ok' ]]; then
    #             instance="$(egrep -o '_[0-9]+' <<< $socket)"
    #             echo "Reloading Hyprland instance $instance"
    #           fi
    #         done
    #       )
    #     '';
    #   };
    # })
  ]);
}
