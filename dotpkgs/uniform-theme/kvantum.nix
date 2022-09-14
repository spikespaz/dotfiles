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

      themeOverrides = lib.mkOption {
        type = types.attrs;
        apply = x: lib.mapAttrs' (name: value:
          if name == "General"
          then { name = "%General"; inherit value; }
          else { inherit name value; }
        ) x;
        default = {};
        example = lib.literalExpression ''
          {
            General = {
              translucent_windows = true;
              reduce_window_opacity = 13;
              reduce_menu_opacity = 13;
            };
            Hacks = {
              transparent_dolphin_view = true;
            };
          }
        '';
        description = lib.mdDoc ''
          Extra configuraton for the Kvantum theme engine.
          See the Kvantum documentation for available options:
          <https://github.com/tsujan/Kvantum/blob/master/Kvantum/doc/Theme-Config>

          Note that the `%General` section can be named `General` in attribute keys,
          the section will be renamed in the configuration output.

          All group names (top-level attributes) must be in `TitleCase`.
        '';
      };
    };
  };

  config = let
    oldThemePath = lib.concatStringsSep "/" [
      cfg.kvantum.themePackage
      "/share/Kvantum/"
      cfg.kvantum.theme
      "${cfg.kvantum.theme}.kvconfig"
    ];
    newThemePath = "${cfg.kvantum.theme}#/${cfg.kvantum.theme}#.kvconfig";
    oldTheme = lib.pipe (
      pkgs.runCommand
        "convert-kvantum-${cfg.kvantum.theme}-to-json"
        { nativeBuildInputs = [ pkgs.jc ]; }
        ''
          mkdir $out
          cat '${oldThemePath}' \
            | "${lib.getExe pkgs.jc}" --ini \
            > "$out/${cfg.kvantum.theme}.json"
        ''
    ) [
      (drv: "${drv}/${cfg.kvantum.theme}.json")
      builtins.readFile
      builtins.fromJSON
    ];
    newTheme = lib.recursiveUpdate oldTheme cfg.kvantum.themeOverrides;
  in lib.mkIf cfg.enable {
    home.packages = [
      cfg.kvantum.package
      cfg.kvantum.themePackage
    ];

    xdg.configFile."Kvantum/kvantum.kvconfig".text = generators.toINI {} {
      General.theme = "${cfg.kvantum.theme}#";
    };

    # todo: fix incorrect casing on some keys,
    # jc does not respect this when the INI parser is used.
    # <https://github.com/kellyjonbrazil/jc/issues/285>
    xdg.configFile."Kvantum/${newThemePath}".text =
      generators.toINI {} newTheme;
  };
}
