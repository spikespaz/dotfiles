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
        default = pkgs.kdePackages.qtstyleplugin-kvantum;
        example = lib.literalExpression ''
          pkgs.libsForQt5.qtstyleplugin-kvantum
        '';
        description = ''
          The package providing the Kvantum theme engine.
        '';
      };

      theme.package = lib.mkOption {
        type = types.package;
        default = pkgs.adwaita-qt;
        example = lib.literalExpression ''
          pkgs.materia-kde-theme
        '';
        description = ''
          The package providing the KDE/Qt/Kvantum theme.
        '';
      };

      theme.name = lib.mkOption {
        type = types.str;
        default = null;
        example = lib.literalExpression ''
          "MateriaDark"
        '';
        description = ''
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
        description = ''
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
  ];
}
