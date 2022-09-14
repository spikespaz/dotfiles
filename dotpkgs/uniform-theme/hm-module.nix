{ self, ... }:
{ config, lib, pkgs, ... }:
let
  description = ''
    Consistent theming between Qt and GTK on Wayland with a custom compositor
    is really not an easy feat. This module contains setup to handle that.
  '';
  inherit (lib) types;
  cfg = config.home.uniformTheme;
in {
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

    dark = lib.mkOption {
      type = types.bool;
      default = false;
      example = lib.literalExpression ''
        true
      '';
      description = lib.mdDoc ''
        Whether the theme names provided are
        supposed to be treated as a dark theme.
      '';
    };

    cursor.package = lib.mkOption {
      type = types.package;
      default = pkgs.vanilla-dmz;
      example = lib.literalExpression ''
        pkgs.quintom-cursor-theme
      '';
      description = lib.mdDoc ''
        The package providing the cursor theme.
      '';
    };

    cursor.name = lib.mkOption {
      type = types.str;
      default = "Vanilla-DMZ";
      example = lib.literalExpression ''
        "Quintom_Ink"
      '';
      description = lib.mdDoc ''
        The name of the cursor theme provided by
        the package (specified in `index.theme`).
      '';
    };

    cursor.size = lib.mkOption {
      type = types.ints.positive;
      default = 24;
      example = lib.mdDoc ''
        `48` for HiDPI
      '';
      description = lib.mdDoc ''
        The point-size of the mouse cursor.
      '';
    };

    icons.package = lib.mkOption {
      type = types.package;
      default = pkgs.gnome.adwaita-icon-theme;
      example = lib.literalExpression ''
        pkgs.papirus-icon-theme
      '';
      description = lib.mdDoc ''
        The package providing the icon theme.
      '';
    };

    icons.name = lib.mkOption {
      type = types.str;
      default = "Adwaita";
      example = lib.literalExpression ''
        "Papirus-Dark"
      '';
      description = lib.mdDoc ''
        The name of the icon theme provided by
        the package (specified in `index.theme`).
      '';
    };

    gtk.package = lib.mkOption {
      type = types.package;
      default = null;
      example = lib.literalExpression ''
        pkgs.materia-theme
      '';
      description = lib.mdDoc ''
        The package providing the GTK theme.
      '';
    };

    gtk.name = lib.mkOption {
      type = types.str;
      default = null;
      example = lib.literalExpression ''
        "Materia-dark-compact"
      '';
      description = lib.mdDoc ''
        The name of the GTK theme provided by
        the package (specified in `index.theme`).
      '';
    };

    fonts.default.package = lib.mkOption {
      type = types.package;
      default = pkgs.noto-fonts;
      example = lib.literalExpression ''
        pkgs.ubuntu_font_family
      '';
      description = lib.mdDoc ''
        The package providing the default regular font.
      '';
    };

    fonts.default.name = lib.mkOption {
      type = types.str;
      default = "Noto Sans";
      example = lib.literalExpression ''
        "Ubuntu"
      '';
      description = lib.mdDoc ''
        The name of the default regular font.
      '';
    };

    fonts.monospace.package = lib.mkOption {
      type = types.package;
      default = pkgs.noto-fonts;
      example = lib.literalExpression ''
        pkgs.ubuntu_font_family
      '';
      description = lib.mdDoc ''
        The package providing the default monospace font.
      '';
    };

    fonts.monospace.name = lib.mkOption {
      type = types.str;
      default = "Noto Sans Mono";
      example = lib.literalExpression ''
        "Ubuntu Mono"
      '';
      description = lib.mdDoc ''
        The name of the default monospace font.
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
