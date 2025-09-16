{ lib, pkgs, ... }:
let
  inherit (lib.birdos.colors) grayRGB listRGB;
  gray = p: listRGB (grayRGB p);

  mkRecolorTheme = attrs:
    pkgs.discord-recolor-theme.override {
      themeName = attrs.themeName;
      overrideVariables = removeAttrs attrs [ "themeName" ];
    };
in {
  programs.vesktop = {
    enable = true;

    settings = {
      arRPC = true;
      clickTrayToShowHide = true;
      discordBranch = "stable";
      hardwareAcceleration = true;
      hardwareVideoAcceleration = true;
      minimizeToTray = true;
      tray = true;
    };

    vencord.themes = {
      gruvbox-darker = with lib.birdos.colors.formats.listRGB.gruvbox.colors;
        mkRecolorTheme {
          themeName = "GruvBox Darker";

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

          font = [ "system-ui" ];
          settingsicons = false;
        };
    };
  };
}
