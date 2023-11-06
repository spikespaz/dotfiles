{ self, lib, ... }:
let
  gruvbox-darker = with lib.birdos.colors.formats.listRGB.gruvbox.colors; {
    accentcolor = neutral_orange;
    accentcolor2 = neutral_purple;
    linkcolor = neutral_blue;
    mentioncolor = neutral_aqua;
    successcolor = bright_green;
    warningcolor = bright_yellow;
    dangercolor = bright_red;

    textbrightest = light0_hard;
    textbrighter = light0;
    textbright = light0;
    textdark = dark4;
    textdarker = dark3;
    textdarkest = dark2;

    backgroundaccent = dark0_hard;
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
      tray = true;
      minimizeToTray = false; # false
      performanceMode = "battery";
      channel = "ptb";
      mods = "vencord";
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
