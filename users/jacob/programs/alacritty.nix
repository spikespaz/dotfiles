{ self, lib, pkgs, ... }:
let
  themes = let
    inherit (lib.birdos.colors) palettes hexRGBA;
    rgb = r: g: b: { inherit r g b; };
    hex = rgb: "#${hexRGBA rgb}";
  in rec {
    gruvbox_dark = let gb = palettes.gruvbox.colors;
    in {
      primary = {
        background = hex gb.dark0_hard;
        dim_foreground = hex gb.light2;
        foreground = hex gb.light1;
        bright_foreground = hex gb.light0;
      };
      dim = {
        black = hex gb.dark1;
        white = hex gb.light2;

        red = hex gb.faded_red;
        green = hex gb.faded_green;
        yellow = hex gb.faded_yellow;
        blue = hex gb.faded_blue;
        magenta = hex gb.faded_purple;
        cyan = hex gb.faded_aqua;
      };
      normal = {
        black = hex gb.dark2;
        white = hex gb.light1;

        red = hex gb.neutral_red;
        green = hex gb.neutral_blue;
        yellow = hex gb.neutral_yellow;
        blue = hex gb.neutral_blue;
        magenta = hex gb.neutral_purple;
        cyan = hex gb.neutral_aqua;
      };
      bright = {
        black = hex gb.dark3;
        white = hex gb.light0;

        red = hex gb.bright_red;
        green = hex gb.bright_green;
        yellow = hex gb.bright_yellow;
        blue = hex gb.bright_blue;
        magenta = hex gb.bright_purple;
        cyan = hex gb.bright_aqua;
      };
    };
    gruvbox_dark_harder = let dark_harder = rgb 18 18 18;
    in gruvbox_dark // {
      primary = gruvbox_dark.primary // { background = hex dark_harder; };
    };
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
