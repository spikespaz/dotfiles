{ self, lib, pkgs, ... }:
let
  inherit (lib.birdos.colors) grayRGB hexRGB';
  gray = percent: hexRGB' (grayRGB percent);

  themes = let inherit (lib.birdos.colors.formats.hexRGB') gruvbox;
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

    gruvbox_dark_harder = lib.recursiveUpdate gruvbox_dark {
      primary.background = gray 7.0e-2; # 7% of each channel
    };
  };
in {
  programs.alacritty.enable = true;

  home.packages = with pkgs; [ nerd-fonts.monaspace ];

  programs.alacritty.settings = {
    terminal.shell = {
      program = "${lib.getExe config.programs.fish.package}";
      args = if pkgs.hostPlatform.isDarwin then [
        "--interactive"
        "--login"
      ] else
        [ "--interactive" ];
    };

    window = {
      opacity = 0.7;
      padding.x = 4;
      padding.y = 2;
      dynamic_padding = true;
    };

    scrolling.history = 100000;

    font = {
      # normal.family = "JetBrainsMono Nerd Font";
      normal.family = "MonaspiceNe Nerd Font";
      size = 11;
    };

    colors = themes.gruvbox_dark_harder;

    bell = {
      animation = "EaseOutQuart";
      duration = 100;
      color = gray 0.25;
    };

    cursor = {
      style.shape = "Beam";
      style.blinking = "Always";
      vi_mode_style = "Block";
    };

    # mouse.hide_when_typing = true;
  };
}
