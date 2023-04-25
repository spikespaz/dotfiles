{ config, pkgs, lib, ... }:
let
  inherit (lib) types;
  cfg = config.xdg.desktopPortals;
in {
  options = {
    xdg.desktopPortals = {
      enable = lib.mkEnableOption (lib.mdDoc "");
      portals = lib.mkOption {
        type = types.listOf types.attrs;
        default = null;
        description = lib.mdDoc "";
        example = lib.literalExpression'''';
      };
    };
  };
  config = lib.mkIf cfg.enable (let
    modifyPortal = { package, interfaces ? null, useIn ? null,
      # environment ? null,
      }:
      pkgs.symlinkJoin {
        inherit (package) name;
        paths = [ package ];
        # nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = ''
          ${lib.optionalString (interfaces != null) ''
            sed -i \
              's@Interfaces=.\+@Interfaces=${
                lib.concatStringsSep ";" interfaces
              };@' \
              $out/share/xdg-desktop-portal/portals/*.portal
          ''}
          ${lib.optionalString (useIn != null) ''
            sed -i \
              's@UseIn=.\+@UseIn=${lib.concatStringsSep ";" useIn};@' \
              $out/share/xdg-desktop-portal/portals/*.portal
          ''}
        '';
        # ${lib.optionalString (environment != null) ''
        #   wrapProgram $out/libexec/xdg-desktop-portal-* \
        #     ${lib.concatStringsSep " " (builtins.attrValues (
        #     builtins.mapAttrs (name: value: "--set ${name} ${value}") environment
        #   ))}
        # ''}
      };
    modifiedPortals = map modifyPortal cfg.portals;
    packages = [ pkgs.xdg-desktop-portal ] ++ modifiedPortals;
    joinedPortals = pkgs.buildEnv {
      name = "xdg-desktop-portals";
      paths = packages;
      pathsToLink =
        [ "/share/xdg-desktop-portal/portals" "/share/applications" ];
    };
  in {
    home.packages = packages;
    home.sessionVariables = {
      # GTK_USE_PORTAL = mkIf cfg.gtkUsePortal "1";
      XDG_DESKTOP_PORTAL_DIR =
        "${joinedPortals}/share/xdg-desktop-portal/portals";
    };
  });
}
