{ config, lib, pkgs, ... }:
let
  description = "Home Manager module for the Kvantum Theme Engine";
  inherit (lib) types generators;
  cfg = config.programs.kvantum;
in {
  options = {
    programs.kvantum = {
      enable = lib.mkEnableOption description;

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

      qt5ct.enable = lib.mkEnableOption ''
        Use the Qt5 Configuration Tool to supply the Qt theme, with
        `QT_QPA_PLATFORMTHEME=qt5ct` as environment variable.
      '';

      qt5ct.package = lib.mkOption {
        type = types.package;
        default = pkgs.libsForQt5.qt5ct;
        example = lib.literalExpression ''
          pkgs.libsForQt5.qt5ct
        '';
        description = lib.mdDoc ''
          The package providing the `qt5ct` binary.
        '';
      };

      qt6ct.enable = lib.mkEnableOption ''
        Use the Qt6 Configuration Tool to supply the Qt theme, with
        `QT_QPA_PLATFORMTHEME=qt6ct` as environment variable.
      '';

      qt6ct.package = lib.mkOption {
        type = types.package;
        # default = pkgs.libsForQt5.qt5ct;
        example = lib.literalExpression ''
          pkgs.qt6ct
        '';
        description = lib.mdDoc ''
          The package providing the `qt6ct` binary.
        '';
      };

      theme.package = lib.mkOption {
        type = types.package;
        default = pkgs.adwaita-qt;
        example = lib.literalExpression ''
          pkgs.materia-kde-theme
        '';
        description = lib.mdDoc ''
          The package providing the KDE/Qt/Kvantum theme.
        '';
      };

      theme.name = lib.mkOption {
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

      theme.overrides = lib.mkOption {
        type = types.attrs;
        apply = lib.mapAttrs' (name: value:
          if name == "General" then {
            name = "%General";
            inherit value;
          } else {
            inherit name value;
          });
        default = { };
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
      cfg.theme.package
      "/share/Kvantum/"
      cfg.theme.name
      "${cfg.theme.name}.kvconfig"
    ];
    newThemePath = "${cfg.theme.name}#/${cfg.theme.name}#.kvconfig";
    oldTheme = lib.pipe
      (pkgs.runCommandLocal "convert-kvantum-${cfg.theme.name}-to-json" { } ''
        mkdir $out
        cat '${oldThemePath}' \
          | '${lib.getExe pkgs.jc}' --ini \
          > "$out/${cfg.theme.name}.json"
      '') [
        (drv: "${drv}/${cfg.theme.name}.json")
        builtins.readFile
        builtins.fromJSON
      ];
    newTheme = lib.recursiveUpdate oldTheme cfg.theme.overrides;
  in lib.mkMerge [
    (lib.mkIf cfg.enable {
      home.packages = [ cfg.package cfg.theme.package ];

      xdg.configFile."Kvantum/kvantum.kvconfig".text =
        generators.toINI { } { General.theme = "${cfg.theme.name}#"; };

      # todo: fix incorrect casing on some keys,
      # jc does not respect this when the INI parser is used.
      # <https://github.com/kellyjonbrazil/jc/issues/285>
      xdg.configFile."Kvantum/${newThemePath}".text =
        generators.toINI { } newTheme;
    })
    (lib.mkIf cfg.qt5ct.enable {
      home.packages = [ cfg.qt5ct.package ];

      home.sessionVariables = { QT_QPA_PLATFORMTHEME = "qt5ct"; };
    })
    (lib.mkIf cfg.qt6ct.enable {
      home.packages = [ cfg.qt6ct.package ];

      home.sessionVariables = { QT_QPA_PLATFORMTHEME = "qt6ct"; };
    })
  ];
}
