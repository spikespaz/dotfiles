# <https://github.com/NixOS/nixpkgs/blob/c8cd81426f45942bb2906d5ed2fe21d2f19d95b7/nixos/modules/programs/wayland/uwsm.nix>
{ config, lib, pkgs, ... }:
let
  inherit (lib) types;
  cfg = config.programs.uwsm;

  desktopSession = lib.types.submodule ({ name, config, ... }: {
    options = {
      fileName = lib.mkOption {
        type = types.singleLineStr;
        description = ''
          The name of the generated `*.desktop` file, without the extension.
        '';
      };
      name = lib.mkOption {
        type = types.singleLineStr;
        description = ''
          The name of the session to be used in the Desktop Entry.
          By default this will be the same as {option}`fileName`.
        '';
      };
      comment = lib.mkOption {
        type = types.singleLineStr;
        description = ''
          The description to be used in the Desktop Entry.
        '';
      };
      exec = lib.mkOption {
        type = types.nullOr types.singleLineStr;
        default = null;
        description = "";
      };
      script = lib.mkOption {
        type = types.nullOr types.lines;
        default = null;
        description = ''
          Lines of shell code to start the desktop session.
        '';
      };
      desktopFile = lib.mkOption {
        type = types.package;
        readOnly = true;
        description = ''
          The generated `*.desktop` file for this session.
          The file is in {path}`$out/share/wayland-sessions/`, so that
          this package can be merged with others via `pkgs.symlinkJoin`.
        '';
      };
    };
    config = {
      fileName = lib.mkDefault name;
      name = lib.mkDefault config.fileName;
      desktopFile = pkgs.writeTextFile {
        name = "${config.fileName}-uswm.desktop";
        text = ''
          [Desktop Entry]
          Name=${config.name}
          ${lib.optionalString (config.comment != null)
          "Comment=${config.comment}"}
          Exec=${lib.getExe cfg.package} start -S -F ${
            if config.exec != null then
              config.exec
            else
              pkgs.writeShellScript "${config.fileName}-uswm-session"
              config.script
          }
          Type=Application
        '';
        destination = "/share/wayland-sessions/${config.fileName}-uwsm.desktop";
        derivationArgs = {
          passthru.providedSessions = [ "${config.fileName}-uwsm" ];
        };
      };
    };
  });
in {
  options.programs.uwsm = {
    desktopSessions = lib.mkOption {
      description = ''
        Configuration for UWSM-managed Wayland Compositors. This
        creates a desktop entry file which will be used by Display
        Managers like GDM, to allow starting the UWSM managed session.
      '';
      type = lib.types.attrsOf desktopSession;
      example = lib.literalExpression ''
        hyprland = {
          prettyName = "Hyprland";
          comment = "Hyprland compositor managed by UWSM";
          binPath = "/run/current-system/sw/bin/Hyprland";
        };
        sway = {
          prettyName = "Sway";
          comment = "Sway compositor managed by UWSM";
          binPath = "/run/current-system/sw/bin/sway";
        };
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.sessionPackages =
      lib.mapAttrsToList (_: { desktopFile, ... }: desktopFile)
      cfg.desktopSessions;

    # I just replaced this option.
    programs.uwsm.waylandCompositors = lib.mkForce { };
  };
}
