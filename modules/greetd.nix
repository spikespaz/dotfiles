{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types;
  cfg = config.services.greetd;

  typeSession = types.submodule {
    options = {
      name = lib.mkOption {
        type = types.singleLineStr;
        # default = "";
        description = lib.mdDoc ''
          The name of the session to be used in the Desktop Entry.
        '';
        example = lib.literalExpression ''TODO'';
      };
      comment = lib.mkOption {
        type = types.singleLineStr;
        # default = "";
        description = lib.mdDoc ''
          The description to be used in the Desktop Entry.
        '';
        example = lib.literalExpression ''TODO'';
      };
      script = lib.mkOption {
        type = types.lines;
        # default = "";
        description = lib.mdDoc ''
          Lines of shell code to start the desktop session.
        '';
      };
    };
  };
in {
  options = {
    services.greetd = {
      sessions = lib.mkOption {
        type = types.attrsOf typeSession;
        default = {};
        description = lib.mdDoc ''TODO'';
        example = lib.literalExpression ''TODO'';
      };
      sessionData = lib.mkOption {
        readOnly = true;
        type = types.package;
        # default = null;
        description = lib.mdDoc ''TODO'';
        example = lib.literalExpression ''TODO'';
      };
    };
  };

  config = {
    services.greetd.sessionData =
      pkgs.runCommand "generate-sessions" {
        passthru.providedSessions = builtins.attrNames cfg.sessions;
      } ''
        mkdir -p $out/share/wayland-sessions

        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (fName: {
            name,
            comment ? null,
            script,
          }: ''
            cat <<- 'EOF' > "$out/share/wayland-sessions/${fName}.desktop"
            [Desktop Entry]
            Name=${name}
            ${lib.optionalString (comment != null) "Comment=${comment}"}
            Exec=${pkgs.writeShellScript "${fName}-wrapped" script}
            Type=Application
            EOF
          '')
          cfg.sessions)}
      '';
  };
}
