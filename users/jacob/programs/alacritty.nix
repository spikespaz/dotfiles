{ self, lib, pkgs, ... }:
let
  themes = let
    inherit (lib.birdos.colors) rgb hexRGB';
    mkRGB = r: g: b: hexRGB' (rgb r g b);

    inherit (lib.birdos.colors.formats.hexRGB') gruvbox;
  in rec {
    gruvbox_dark = with gruvbox.colors; {
      primary = {
        background = dark0_hard;
        dim_foreground = light2;
        foreground = light1;
        bright_foreground = light0;
      };
      dim = {
        black = dark1;
        white = light2;

        red = faded_red;
        green = faded_green;
        yellow = faded_yellow;
        blue = faded_blue;
        magenta = faded_purple;
        cyan = faded_aqua;
      };
      normal = {
        black = dark2;
        white = light1;

        red = neutral_red;
        green = neutral_green;
        yellow = neutral_yellow;
        blue = neutral_blue;
        magenta = neutral_purple;
        cyan = neutral_aqua;
      };
      bright = {
        black = dark3;
        white = light0;

        red = bright_red;
        green = bright_green;
        yellow = bright_yellow;
        blue = bright_blue;
        magenta = bright_purple;
        cyan = bright_aqua;
      };
      indexed_colors = gruvbox.indexed;
    };

    gruvbox_dark_harder = let dark_harder = mkRGB 18 18 18;
    in lib.recursiveUpdate gruvbox_dark { primary.background = dark_harder; };
  };
in {
  imports = [ self.homeManagerModules.alacritty ];

  programs.alacritty.enable = true;

  home.packages =
    [ (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) ];

  programs.alacritty.settings.shell = {
    program = "${lib.getExe pkgs.zsh}";
    args = [ "--login" ];
  };

  programs.alacritty.settings = {
    window = {
      opacity = 0.7;
      padding.x = 4;
      padding.y = 2;
      dynamic_padding = true;
    };

    scrolling.history = 100000;

    font = {
      normal.family = "JetBrainsMono Nerd Font";
      size = 9;
    };

    colors = themes.gruvbox_dark_harder;

    bell = {
      animation = "EaseOutQuart";
      duration = 100;
      color = "#404040";
    };

    cursor = {
      style.shape = "Beam";
      style.blinking = "Always";
      vi_mode_style = "Block";
    };

    # mouse.hide_when_typing = true;
  };
}
