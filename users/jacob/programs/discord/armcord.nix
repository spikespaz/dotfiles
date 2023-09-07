{ lib, pkgs, ... }:
let
  package = pkgs.armcord;
  configDir = "ArmCord";

  # <https://github.com/mwittrien/BetterDiscordAddons/blob/master/Themes/DiscordRecolor/DiscordRecolor.theme.css>
  # defaultTheme = colorSchemes.default // themeSettings.default;

  theme = colorSchemes.default // {
    font = [ "system-ui" ];
    settingsicons = false;
  };

  colorSchemes = {
    default = {
      accentcolor = [ 88 101 242 ];
      accentcolor2 = [ 255 115 250 ];
      linkcolor = [ 0 176 244 ];
      mentioncolor = [ 250 166 26 ];
      successcolor = [ 59 165 92 ];
      warningcolor = [ 250 166 26 ];
      dangercolor = [ 237 66 69 ];

      textbrightest = [ 255 255 255 ];
      textbrighter = [ 222 222 222 ];
      textbright = [ 185 185 185 ];
      textdark = [ 140 140 140 ];
      textdarker = [ 115 115 115 ];
      textdarkest = [ 80 80 80 ];

      backgroundaccent = [ 50 50 50 ];
      backgroundprimary = [ 30 30 30 ];
      backgroundsecondary = [ 20 20 20 ];
      backgroundsecondaryalt = [ 15 15 15 ];
      backgroundtertiary = [ 10 10 10 ];
      backgroundfloating = [ 0 0 0 ];
    };
  };

  themeSettings = {
    default = {
      font = [
        "gg sans"
        "Noto Sans"
        "Helvetica Neue"
        "Helvetica"
        "Arial"
        "sans-serif"
      ];
      settingsicons = true;
    };
  };

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
      @import url(https://mwittrien.github.io/BetterDiscordAddons/Themes/DiscordRecolor/DiscordRecolor.css);
      :root {
        ${lib.concatStringsSep "\n  " (mkCssVarLines vars)}
      }
    '';
in {
  home.packages = [ package ];

  xdg.configFile."${configDir}/storage/settings.json".text = builtins.toJSON {
    windowStyle = "native";
    channel = "ptb";
    armcordCSP = true;
    minimizeToTray = false;
    automaticPatches = false;
    keybinds = [ ];
    alternativePaste = false;
    multiInstance = false;
    mods = "vencord";
    spellcheck = true;
    performanceMode = "battery";
    skipSplash = false;
    inviteWebsocket = true;
    startMinimized = false;
    dynamicIcon = false;
    tray = true;
    customJsBundle = "https://armcord.app/placeholder.js";
    customCssBundle = "https://armcord.app/placeholder.css";
    disableAutogain = false;
    useLegacyCapturer = false;
    mobileMode = false;
    trayIcon = "default";
    doneSetup = true;
    clientName = "ArmCord";
    customIcon = "${package}/opt/ArmCord/resources/app.asar/assets/desktop.png";
  };

  xdg.configFile."${configDir}/themes/DiscordRecolor-BD/manifest.json".text =
    builtins.toJSON {
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
      source =
        "https://github.com/mwittrien/BetterDiscordAddons/tree/master/Themes/DiscordRecolor/";
      # updateSrc = "redacted because we don't want it to update";
      supportsArmCordTitlebar = false;
    };

  xdg.configFile."${configDir}/themes/DiscordRecolor-BD/theme.css".text =
    mkRecolorTheme theme;
}
