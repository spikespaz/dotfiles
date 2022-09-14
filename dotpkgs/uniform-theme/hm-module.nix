{ ... }:
{ config, lib, pkgs, ... }:
let
  description = ''
    Consistent theming between Qt and GTK on Wayland with a custom compositor
    is really not an easy feat. This module contains setup to handle that.
  '';
  inherit (lib) types;
  cfg = config.home.uniformTheme;
in {
  imports = [
    ./options.nix
    ./kvantum.nix
  ];

  options.home.uniformTheme = {
    enable = lib.mkEnableOption description;

    qt5ct.package = lib.mkOption {
      type = types.package;
      default = pkgs.libsForQt5.qt5ct;
      example = lib.literalExpression ''
        pkgs.libsForQt5.qt5ct
      '';
      description = lib.mdDoc ''
        The package providing the *qt5ct* style manager.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # specify packages that are required for some stuff below
    home.packages = [
      cfg.qt5ct.package
      cfg.fonts.monospace.package
    ];

    # use qt5ct in tandem with kvantum
    home.sessionVariables = {
      QT_QPA_PLATFORMTHEME = "qt5ct";
    };

    # specify packages to use for gtk theming
    gtk = {
      enable = true;

      iconTheme.package = cfg.icons.package;
      iconTheme.name = cfg.icons.name;

      theme.package = cfg.gtk.package;
      theme.name = cfg.gtk.name;

      font.package = cfg.fonts.default.package;
      font.name = cfg.fonts.default.name;
    };

    # libadwaita doesn't respect any precedent
    dconf.settings."org/gnome/desktop/interface" = {
      monospace-font-name = cfg.fonts.monospace.name;
      # required for libadwaita
      color-scheme = if cfg.dark then "prefer-dark" else "prefer-light";
      # don't know if this is needed
      # cursor-size = 24;
    };

    home.pointerCursor = {
      package = cfg.cursor.package;
      name = cfg.cursor.name;
      size = cfg.cursor.size;
      gtk.enable = true;
      x11.enable = true;
    };

    # should cover any other bases
    home.sessionVariables = {
      XCURSOR_SIZE = "${toString cfg.cursor.size}";
    };
  };
}
