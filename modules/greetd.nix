{ config, lib, pkgs, ... }:
let
  inherit (lib) types;
  cfg = config.services.greetd;

  desktopSession = types.submodule ({ name, config, ... }: {
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
      script = lib.mkOption {
        type = types.lines;
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
      desktopFile =
        pkgs.writeTextDir "share/wayland-sessions/${config.fileName}.desktop" ''
          [Desktop Entry]
          Name=${config.name}
          ${lib.optionalString (config.comment != null)
          "Comment=${config.comment}"}
          Exec=${
            pkgs.writeShellScript "${config.fileName}-session" config.script
          }
          Type=Application
        '';
    };
  });
in {
  options = {
    services.greetd = {
      sessions = lib.mkOption {
        type = types.attrsOf desktopSession;
        default = { };
        description = ''
          Attribute set of desktop session specifications.
          Each attribute name will be used as the name of the
          corresponding `*.desktop` file, as well as the name of the session
          in the generated fule, unless otherwise specified.
        '';
        example = lib.literalExpression "TODO";
      };

      nixosIntegration = lib.mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to add `sessionFiles` to
          {option}`services.xserver.displayManager.sessionPackages`
          in order to integrate greetd's sessions with other modules provided by NixOS.
        '';
      };

      sessionFiles = lib.mkOption {
        type = types.package;
        readOnly = true;
        description = ''
          The final package of joined `*.desktop` files in
          {path}`$out/share/wayland-sessions`.
        '';
      };

      sessionPath = lib.mkOption {
        type = types.listOf types.path;
        apply = lib.concatStringsSep ":";
        description = ''
          This option is intended to be used recursively in your greetd
          configuration. For example, this value is appropriate for
          tuigreet's `--sessions` parameter.
        '';
      };
    };
  };

  config = lib.mkMerge [
    {
      services.greetd.sessionFiles = pkgs.symlinkJoin {
        name = "greetd-session-desktop-files";
        paths =
          lib.mapAttrsToList (_: session: session.desktopFile) cfg.sessions;
        passthru.providedSessions =
          lib.mapAttrsToList (_: session: session.fileName) cfg.sessions;
      };
    }
    (lib.mkIf cfg.nixosIntegration {
      services.xserver.displayManager.sessionPackages = [ cfg.sessionFiles ];
      services.greetd.sessionPath = let
        sessionPackage =
          config.services.xserver.displayManager.sessionData.desktops;
      in [
        "${sessionPackage}/share/xsessions"
        "${sessionPackage}/share/wayand-sessions"
      ];
    })
    (lib.mkIf (!cfg.nixosIntegration) {
      services.greetd.sessionPath = [
        "${cfg.sessionFiles}/share/xsessions"
        "${cfg.sessionFiles}/share/wayland-sessions"
      ];
    })
  ];
}

