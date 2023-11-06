{ lib, pkgs, config, ... }:
let
  inherit (lib) types;
  cfg = config.programs.armcord;
  jsonFormat = pkgs.formats.json { };
  configDir = "ArmCord";
in {
  options = {
    programs.armcord = {
      enable = lib.mkEnableOption "ArmCord";
      package = lib.mkPackageOption pkgs "armcord" { };

      settings = lib.mkOption {
        type = jsonFormat.type;
        default = { };
        description = ''
          Settings to use in {file}`~/.config/${configDir}/storage/settings.json`.
        '';
      };

      recolorTheme = {
        enable = lib.mkEnableOption "ArmCord with DiscordRecolor theme";

        url = lib.mkOption {
          type = types.singleLineStr;
          default =
            "https://mwittrien.github.io/BetterDiscordAddons/Themes/DiscordRecolor/DiscordRecolor.css";
        };

        colors = lib.mkOption {
          type = types.lazyAttrsOf (types.listOf (types.ints.between 0 255));
          default = { };
          description = ''
            A map of colors, specified as a list of RGB channels.
          '';
        };

        extras = lib.mkOption {
          type = let
            atom = types.nullOr
              (types.oneOf [ types.bool types.singleLineStr types.int ]);
            collection = types.listOf atom;
          in types.lazyAttrsOf (types.either atom collection);
          default = { };
          description = ''
            A map of extra CSS variables to set.
          '';
        };
      };
    };
  };

  config = let
    mkRecolorTheme = vars:
      let
        mkCssValue = expr:
          if lib.isString expr then
            ''"${expr}"''
          else if lib.isBool expr then
            if expr then "1" else "0"
          else if lib.isInt expr then
            toString expr
          else if lib.isList expr then
            lib.concatMapStringsSep ", " mkCssValue expr
          else
            abort ''
              Expression cannot be converted to a CSS value.
              Valid Nix types: int, string, list.
            '';
        mkCssVarLines =
          lib.mapAttrsToList (name: value: "--${name}: ${mkCssValue value};");
      in ''
        @import url(${cfg.recolorTheme.url});
        :root {
          ${lib.concatStringsSep "\n  " (mkCssVarLines vars)}
        }
      '';
  in lib.mkIf cfg.enable (lib.mkMerge [
    { home.packages = [ cfg.package ]; }

    (lib.mkIf (cfg.settings != { }) {
      xdg.configFile."${configDir}/storage/settings.json".source =
        jsonFormat.generate "armcord-settings.json" cfg.settings;
    })

    (lib.mkIf cfg.recolorTheme.enable {
      xdg.configFile."${configDir}/themes/DiscordRecolor-BD/manifest.json".source =
        jsonFormat.generate "armcord-recolor-manifest.json" {
          theme = "theme.css";
          name = "DiscordRecolor";
          description = "Allows you to customize Discord's native Color Scheme";
          author = "DevilBro";
          version = "1.0.0";
          authorId = "278543574059057154";
          invite = "Jx3TjNS";
          donate = "https://www.paypal.me/MircoWittrien";
          patreon = "https://www.patreon.com/MircoWittrien";
          website = "https://mwittrien.github.io/";
          source = cfg.recolorTheme.url;
          # updateSrc = "redacted because we don't want it to update";
          supportsArmCordTitlebar = false;
        };
    })

    (lib.mkIf (cfg.recolorTheme.enable && ((cfg.recolorTheme.colors != { }
      || (cfg.recolorTheme.extras != { })))) {
        xdg.configFile."${configDir}/themes/DiscordRecolor-BD/theme.css".text =
          mkRecolorTheme (cfg.recolorTheme.colors // cfg.recolorTheme.extras);
      })
  ]);
}
