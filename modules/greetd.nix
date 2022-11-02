{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types;
  cfg = config.services.greetd;
in {
  options = {
    services.greetd = {
      sessions = lib.mkOption {
        type = types.attrsOf types.attrs;
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
            Exec=${pkgs.writeShellScriptBin "${fName}-wrapped.sh" script}
            Type=Application
            EOF
          '')
          cfg.sessions)}
      '';
  };
}
