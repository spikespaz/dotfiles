{ lib, pkgs, config, ... }:
let
  inherit (lib) types;
  cfg = config.programs.vesktop;
  # jsonFormat = pkgs.formats.json { };
  settingsDir = "VencordDesktop/VencordDesktop";

  # #  <https://github.com/ArmCord/ArmCord/blob/dev/src/utils.ts#L46>
  # defaultSettings = {
  #   windowStyle = "default";
  #   channel = "stable";
  #   armcordCSP = true;
  #   minimizeToTray = true;
  #   automaticPatches = false;
  #   keybinds = [ ];
  #   alternativePaste = false;
  #   multiInstance = false;
  #   mods = "none";
  #   spellcheck = true;
  #   performanceMode = "none";
  #   skipSplash = false;
  #   inviteWebsocket = true;
  #   startMinimized = false;
  #   dynamicIcon = false;
  #   tray = true;
  #   customJsBundle = "https://armcord.app/placeholder.js";
  #   customCssBundle = "https://armcord.app/placeholder.css";
  #   disableAutogain = false;
  #   useLegacyCapturer = false;
  #   mobileMode = false;
  #   trayIcon = "default";
  #   doneSetup = false;
  #   clientName = "ArmCord";
  # };

  # # Overrides to make ArmCord play nice with bare-bones WMs.
  # nixosSettings = defaultSettings // {
  #   windowStyle = "native";
  #   # Someone might not have a tray.
  #   tray = false;
  #   minimizeToTray = false;
  #   # Because it is configured declaratively.
  #   doneSetup = true;
  # };
in {
  options = {
    programs.vesktop = {
      enable = lib.mkEnableOption "Vesktop";
      package = lib.mkPackageOption pkgs "vesktop" { };

      # settings = lib.mkOption {
      #   type = jsonFormat.type;
      #   default = nixosSettings;
      #   description = ''
      #     Settings to use in {file}`~/.config/${configDir}/storage/settings.json`.

      #     Set this to `{ }` to not link the file, and let it be read-write.
      #   '';
      # };

      recolorTheme = {
        enable = lib.mkEnableOption "ArmCord with DiscordRecolor theme";

        url = lib.mkOption {
          type = types.singleLineStr;
          default =
            "https://raw.githubusercontent.com/mwittrien/BetterDiscordAddons/master/Themes/DiscordRecolor/DiscordRecolor.css";
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
        :root {
          ${lib.concatStringsSep "\n  " (mkCssVarLines vars)}
        }
      '';
  in lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [ cfg.package ];
    }

    # (lib.mkIf (cfg.settings != { }) {
    #   xdg.configFile."${configDir}/storage/settings.json".source =
    #     jsonFormat.generate "armcord-settings.json"
    #     (nixosSettings // cfg.settings);
    # })

    # (lib.mkIf cfg.recolorTheme.enable {
    #   # https://github.com/ArmCord/ArmCord/blob/dev/src/themeManager/main.ts#L8
    #   xdg.configFile."${configDir}/themes/DiscordRecolor-BD/manifest.json".source =
    #     jsonFormat.generate "armcord-recolor-manifest.json" {
    #       name = "DiscordRecolor";
    #       author = "DevilBro";
    #       description = "Allows you to customize Discord's native Color Scheme";
    #       version = "1.0.0";
    #       invite = "Jx3TjNS";
    #       authorId = "278543574059057154";
    #       theme = "theme.css";
    #       donate = "https://www.paypal.me/MircoWittrien";
    #       patreon = "https://www.patreon.com/MircoWittrien";
    #       website = "https://mwittrien.github.io/";
    #       source = cfg.recolorTheme.url;
    #       # updateSrc = "redacted because we don't want it to update";
    #       # supportsArmCordTitlebar = false;
    #     };
    # })

    (lib.mkIf (cfg.recolorTheme.enable && ((cfg.recolorTheme.colors != { }
      || (cfg.recolorTheme.extras != { })))) {
        xdg.configFile."${settingsDir}/themes/DiscordRecolor.theme.css".text =
          # REDACTED
          # * @updateUrl https://mwittrien.github.io/BetterDiscordAddons/Themes/DiscordRecolor/DiscordRecolor.theme.css
          ''
            /**
              * @name DiscordRecolor
              * @description Allows you to customize Discord's native Color Scheme
              * @author DevilBro
              * @version 1.0.0
              * @authorId 278543574059057154
              * @invite Jx3TjNS
              * @donate https://www.paypal.me/MircoWittrien
              * @patreon https://www.patreon.com/MircoWittrien
              * @website https://mwittrien.github.io/
              * @source https://github.com/mwittrien/BetterDiscordAddons/tree/master/Themes/DiscordRecolor/
              *
              * @var checkbox    settingsicons_s             "User Settings Icons"                            1
              * @var text        font_s                      "General Font"                                   "gg sans", "Noto Sans"
              * @var text        accentcolor_s               "Blurple Color: [default] = 88, 101, 242"        88,  101, 242
              * @var text        accentcolor2_s              "Boost Pink Color: [default] = 255, 115, 250"    255, 115, 250
              * @var text        linkcolor_s                 "Link Color: [default] = 0, 176, 244"            0,   176, 244
              * @var text        mentioncolor_s              "Mentioned Color: [default] = 250, 166, 26"      250, 166, 26
              * @var text        successcolor_s              "Success Color: [default] = 59, 165, 92"         59,  165, 92
              * @var text        warningcolor_s              "Warning Color: [default] = 250, 166, 26"        250, 166, 26
              * @var text        dangercolor_s               "Danger Color: [default] = 237, 66, 69"          237, 66,  69
              * @var text        textbrightest_s             "Text Color 1: [default] = 255, 255, 255"        255, 255, 255
              * @var text        textbrighter_s              "Text Color 2: [default] = 220, 221, 222"        222, 222, 222
              * @var text        textbright_s                "Text Color 3: [default] = 185, 187, 190"        185, 185, 185
              * @var text        textdark_s                  "Text Color 4: [default] = 142, 146, 151"        140, 140, 140
              * @var text        textdarker_s	               "Text Color 5: [default] = 114, 118, 125"        115, 115, 115
              * @var text        textdarkest_s               "Text Color 6: [default] = 79, 84, 92"           80,  80,  80
              * @var text        backgroundaccent_s          "Background Accent: [default] = 64, 68, 75"      50,  50,  50
              * @var text        backgroundprimary_s         "Background 1: [default] = 54, 57, 63"           30,  30,  30
              * @var text        backgroundsecondary_s       "Background 2: [default] = 47, 49, 54"           20,  20,  20
              * @var text        backgroundsecondaryalt_s    "Background 3: [default] = 41, 43, 47"           15,  15,  15
              * @var text        backgroundtertiary_s        "Background 4: [default] = 32, 34, 37"           10,  10,  10
              * @var text        backgroundfloating_s        "Background Elevated: [default] = 24, 25, 28"    0,   0,   0
            */

            @import url(${cfg.recolorTheme.url});

            ${mkRecolorTheme
            (cfg.recolorTheme.colors // cfg.recolorTheme.extras)}
          '';
      })
  ]);
}
