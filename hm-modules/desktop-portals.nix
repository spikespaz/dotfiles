{ config, pkgs, lib, ... }:
let
  inherit (lib) types;
  cfg = config.xdg.desktopPortals;

  xdgPortal = types.submodule ({ config, name, ... }: {
    options = {
      package = lib.mkOption {
        type = types.package;
        description = lib.mdDoc ''
          The package of the XDG portal to include.
        '';
      };
      portalName = lib.mkOption {
        type = types.singleLineStr;
        default = name;
        description = lib.mdDoc ''
          The name of the `*.portal` file without the file extension,
          relative to the package's `$out/share/xdg-desktop-portal/portals`
          directory.

          For example with the {package}`pkgs.xdg-desktop-portal-wlr` package,
          whose `pname` is `xdg-desktop-portal-wlr`, the default value for this
          option should be `wlr`.
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

      frontendPackage = lib.mkOption {
        type = types.package;
        default = pkgs.xdg-desktop-portal;
        description = lib.mdDoc ''
          The frontend service package that provides the DBus integration.

          This option is not for backend portal packages.
        '';
      };

      # <https://github.com/NixOS/nixpkgs/blob/f155f0cf4ea43c4e3c8918d2d327d44777b6cad4/nixos/modules/config/xdg/portal.nix#L65-L75>
      xdgOpenUsePortal = lib.mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc ''
          Set environment variable `NIXOS_XDG_OPEN_USE_PORTAL` to `1`.

          This will make `xdg-open` use the portal to open programs,
          which resolves bugs involving programs opening inside FHS environments
          or with unexpected environment variables set from wrappers.

          See [nixpkgs#160923](https://github.com/NixOS/nixpkgs/issues/160923) for more information.
        '';
      };

      portals = lib.mkOption {
        type = types.attrsOf xdgPortal;
        default = { };
        description = lib.mdDoc ''
          An attribute set of portal specifications.

          The name should match the name of the package's main `*.portal` file,
          without the file extension.

          See the documentation of this option type for more information.
        '';
        example = lib.literalExpression ''
          {
            wlr = {
              package = pkgs.xdg-desktop-portal-wlr;
              useIn = ["sway"];
            };
            kde = {
              package = pkgs.libsForQt5.xdg-desktop-portal-kde;
              # Only the `FileChooser` interface is desired.
              interfaces = [ "org.freedesktop.impl.portal.FileChooser" ];
              useIn = ["sway"];
            };
          }
        '';
      };
    };
  };
  config = let
    portalPackages =
      lib.mapAttrsToList (name: value: value.finalPackage) cfg.portals;
    joinedPortals = pkgs.buildEnv {
      name = "xdg-desktop-portals";
      paths = portalPackages;
      pathsToLink =
        [ "/share/xdg-desktop-portal/portals" "/share/applications" ];
    };
  in lib.mkIf cfg.enable {
    home.packages = [ cfg.frontendPackage ] ++ portalPackages;
    home.sessionVariables = {
      XDG_DESKTOP_PORTAL_DIR =
        "${joinedPortals}/share/xdg-desktop-portal/portals";
      NIXOS_XDG_OPEN_USE_PORTAL = lib.mkIf cfg.xdgOpenUsePortal "1";
    };
  };
}
