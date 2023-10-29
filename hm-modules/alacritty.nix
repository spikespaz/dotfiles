# This is a copy of the default HM module as of 2023-10-28,
# but it has updated for the new configuration file using TOML
# which will be introduced in Alacritty 0.13.0.
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.alacritty;
  tomlFormat = pkgs.formats.toml { };
in {
  disabledModules = [ "programs/alacritty.nix" ];

  options = {
    programs.alacritty = {
      enable = lib.mkEnableOption "Alacritty";

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.alacritty;
        defaultText = lib.literalExpression "pkgs.alacritty";
        description = "The Alacritty package to install.";
      };

      settings = lib.mkOption {
        type = tomlFormat.type;
        default = { };
        example = lib.literalExpression ''
          {
            window.dimensions = {
              lines = 3;
              columns = 200;
            };
            key_bindings = [
              {
                key = "K";
                mods = "Control";
                chars = "\\x0c";
              }
            ];
          }
        '';
        description = ''
          Configuration written to
          {file}`$XDG_CONFIG_HOME/alacritty/alacritty.yml`. See
          <https://github.com/alacritty/alacritty/blob/master/alacritty.yml>
          for the default configuration.
        '';
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home.packages = [ cfg.package ];

      xdg.configFile."alacritty/alacritty.toml" =
        lib.mkIf (cfg.settings != { }) {
          source = tomlFormat.generate "alacritty.toml" cfg.settings;
        };
    })
  ];
}
