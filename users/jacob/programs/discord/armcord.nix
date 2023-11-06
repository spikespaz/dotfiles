{ self, lib, config, ... }:
let
  gruvbox-darker = let
    gb = builtins.mapAttrs (_: { r, g, b }: [ r g b ])
      lib.birdos.colors.palettes.gruvbox.dark;
  in {
    accentcolor = gb.hl_orange;
    accentcolor2 = gb.fg_purple;
    linkcolor = gb.fg_blue;
    mentioncolor = gb.fg_aqua;
    successcolor = gb.hl_green;
    warningcolor = gb.hl_yellow;
    dangercolor = gb.hl_red;

    textbrightest = gb.fg0;
    textbrighter = gb.fg0;
    textbright = gb.fg1;
    textdark = gb.bg4;
    textdarker = gb.bg3;
    textdarkest = gb.bg2;

    backgroundaccent = gb.bg0_soft;
    backgroundprimary = [ 20 20 20 ];
    backgroundsecondary = [ 16 16 16 ];
    backgroundsecondaryalt = [ 12 12 12 ];
    backgroundtertiary = [ 10 10 10 ];
    backgroundfloating = [ 0 0 0 ];
  };
in {
  imports = [ self.homeManagerModules.armcord ];

  programs.armcord = {
    enable = true;
    settings = {
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
      customIcon =
        "${config.programs.armcord.package}/opt/ArmCord/resources/app.asar/assets/desktop.png";
    };
    recolorTheme = {
      enable = true;
      colors = gruvbox-darker;
      extras = {
        font = [ "system-ui" ];
        settingsicons = false;
      };
    };
  };
}
