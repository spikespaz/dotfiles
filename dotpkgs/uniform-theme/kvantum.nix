{ config, lib, pkgs, ... }:
let
  inherit (lib) types generators;
  cfg = config.home.uniformTheme;
in {
  options = {
    home.uniformTheme.kvantum = {
      package = lib.mkOption {
        type = types.package;
        default = pkgs.libsForQt5.qtstyleplugin-kvantum;
        example = lib.literalExpression ''
          pkgs.libsForQt5.qtstyleplugin-kvantum
        '';
        description = lib.mdDoc ''
          The package providing the Kvantum theme engine.
        '';
      };

      themePackage = lib.mkOption {
        type = types.package;
        default = pkgs.adwaita-qt;
        example = lib.literalExpression ''
          pkgs.materia-kde-theme
        '';
        description = lib.mdDoc ''
          The package providing the KDE/Qt/Kvantum theme.
        '';
      };

      theme = lib.mkOption {
        type = types.str;
        default = null;
        example = lib.literalExpression ''
          "MateriaDark"
        '';
        description = lib.mdDoc ''
          The name of the KDE/Qt/Kvantum theme provided by
          the package (specified in `index.theme`).
        '';
      };

      themeExtraConfig = lib.mkOption {
        type = types.attrs;
        default = {};
        example = lib.literalExpression ''
          {}
        '';
        description = lib.mdDoc ''
          Extra configuraton for the Kvantum theme engine.
          See the Kvantum documentation for available options:
          <https://github.com/tsujan/Kvantum/blob/master/Kvantum/doc/Theme-Config>
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.kvantum.package
      cfg.kvantum.themePackage
    ];

    xdg.configFile."Kvantum/kvantum.kvconfig".text = generators.toINI {} {
      general.theme = "${cfg.kvantum.theme}#";
    };
  };
}
