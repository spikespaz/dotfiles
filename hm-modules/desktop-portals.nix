{ config, pkgs, lib, ... }:
let
  inherit (lib) types;
  cfg = config.xdg.desktopPortals;

  xdgPortal = types.submodule ({ config, ... }: {
    options = {
      package = lib.mkOption {
        type = types.package;
        description = lib.mdDoc ''
          The package of the XDG portal to include.
        '';
      };
      portalName = lib.mkOption {
        type = types.singleLineStr;
        defaultText = lib.mdDoc ''
          This is the name of the main `*.portal` file in the package,
          with the file extension removed.

          By default, it is assumed that the `*.portal` file is named the
          same as the package with the `xdg-desktop-portal-` prefix removed.

          For example with the {package}`pkgs.xdg-desktop-portal-wlr` package,
          whose `pname` is `xdg-desktop-portal-wlr`, the default value for this
          option would be `wlr`.
        '';
        description = lib.mdDoc ''
          The name of the `*.portal` file without the suffix, relative to
          the package's `$out/share/xdg-desktop-portal/portals` directory.
        '';
      };
      useIn = lib.mkOption {
        type = types.nullOr (types.listOf types.singleLineStr);
        default = null;
        description = lib.mdDoc ''
          An optional list of desktops for which to enable the portal.

          Enabling the portal depends on whether it's `UseIn` list contains
          the value of `$XDG_CURRENT_DESKTOP`.

          Defining this option will *overwrite* the values set by the portal's
          `*.portal` file. If you have multiple desktop environments,
          or a heavily customized desktop, it is recommended to specify this.

          You will also need to use this option if your desktop is not
          officially supported by the portal package.
        '';
      };
      interfaces = lib.mkOption {
        type = types.nullOr (types.listOf types.singleLineStr);
        default = null;
        description = lib.mdDoc ''
          An optional list of interfaces which the portal should be used for.

          This option is provided in order to eliminate conflicts between portals.
          Because interfaces are chosen from all of your installed portals
          lexical order by their name, it is recommended to be vary careful
          and only enable the interfaces from each portal that you need.

          For example, you could use {package}`pkgs.libsForQt5.xdg-desktop-portal-kde`
          for `org.freedesktop.impl.portal.FileChooser` and `pkgs.xdg-desktop-portal-wlr`
          for everything else. Remember to consult the portal package's
          original `*.portal` file to see what is available.

          Defining this option will *overwrite* the interfaces listed in
          the `*.portal` file.
        '';
      };
      finalPackage = lib.mkOption {
        type = types.package;
        readOnly = true;
      };
    };
    config = {
      portalName = lib.mkDefault (lib.pipe config.package.pname [
        (lib.removePrefix "xdg-desktop-portal-")
        (lib.removeSuffix ".portal")
      ]);
      finalPackage = pkgs.symlinkJoin {
        inherit (config.package) name pname version;
        paths = [ config.package ];
        postBuild = ''
          portal_file=$out/share/xdg-desktop-portal/portals/${config.portalName}.portal
          ${lib.optionalString (config.interfaces != null) ''
            sed -i \
              's@Interfaces=.\+@Interfaces=${
                lib.concatStringsSep ";" config.interfaces
              };@' \
              $portal_file
          ''}
          ${lib.optionalString (config.useIn != null) ''
            sed -i \
              's@UseIn=.\+@UseIn=${lib.concatStringsSep ";" config.useIn};@' \
              $portal_file
          ''}
        '';
      };
    };
  });
in {
  options = {
    xdg.desktopPortals = {
      enable = lib.mkEnableOption (lib.mdDoc "");

      portals = lib.mkOption {
        type = types.listOf xdgPortal;
        default = [ ];
        description = lib.mdDoc "";
        example = lib.literalExpression "";
      };
    };
  };
  config = let
    portalPackages = [ pkgs.xdg-desktop-portal ]
      ++ map (it: it.finalPackage) cfg.portals;
    joinedPortals = pkgs.buildEnv {
      name = "xdg-desktop-portals";
      paths = portalPackages;
      pathsToLink =
        [ "/share/xdg-desktop-portal/portals" "/share/applications" ];
    };
  in lib.mkIf cfg.enable {
    home.packages = portalPackages;
    home.sessionVariables = {
      XDG_DESKTOP_PORTAL_DIR =
        "${joinedPortals}/share/xdg-desktop-portal/portals";
    };
  };
}
