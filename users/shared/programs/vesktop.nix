{ self, lib, ... }:
let
  inherit (lib.birdos.colors) grayRGB listRGB formats;
  gray = p: listRGB (grayRGB p);

  gruvbox-darker = with formats.listRGB.gruvbox.colors; {
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

    backgroundaccent = gray 0.12;
    backgroundprimary = gray 8.0e-2;
    backgroundsecondary = gray 6.0e-2;
    backgroundsecondaryalt = gray 5.0e-2;
    backgroundtertiary = gray 4.0e-2;
    backgroundfloating = gray 0;
  };
in {
  imports = [ self.homeManagerModules.vesktop ];

  programs.vesktop = {
    enable = true;
    # settings = {
    #   tray = true;
    #   minimizeToTray = false; # false
    #   performanceMode = "battery";
    #   channel = "ptb";
    #   mods = "vencord";
    # };

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
