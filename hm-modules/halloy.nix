{ lib, pkgs, config, ... }:
let
  inherit (lib) types;
  cfg = config.programs.halloy;
  yamlFormat = pkgs.formats.yaml { };
in {
  options = {
    programs.halloy = {
      enable = lib.mkEnableOption "Halloy - Rusty and Fast IRC Client";

      package = lib.mkPackageOption pkgs "halloy" { };

      settings = lib.mkOption {
        type = yamlFormat.type;
        default = { };
        description = "";
        example = lib.literalExpression "";
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    { home.packages = [ cfg.package ]; }
    (lib.mkIf (cfg.settings != {}) {
      xdg.configFile."halloy/config.yaml".source =
        yamlFormat.generate "halloy-config.yaml" cfg.settings;
    })
  ]);
}
