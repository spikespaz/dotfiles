let
  gruvbox_dark = {
    primary = {
      background = "0x282828";
      foreground = "0xebdbb2";
    };
    normal = {
      black = "0x282828";
      red = "0xcc241d";
      green = "0x98971a";
      yellow = "0xd79921";
      blue = "0x458588";
      magenta = "0xb16286";
      cyan = "0x689d6a";
      white = "0xa89984";
    };
    bright = {
      black = "0x928374";
      red = "0xfb4934";
      green = "0xb8bb26";
      yellow = "0xfabd2f";
      blue = "0x83a598";
      magenta = "0xd3869b";
      cyan = "0x8ec07c";
      white = "0xebdbb2";
    };
  };
  gruvbox_dark_custom = gruvbox_dark // {
    primary.background = "0x121212";
    normal.black = "0x5c5c5c";
  };
in {
  programs.alacritty.enable = true;

  programs.alacritty.settings = {
    window = {
      opacity = 0.7;
      padding.x = 4;
      padding.y = 0;
      dynamic_padding = true;
    };

    scrolling.history = 100000;

    font = {
      normal.family = "JetBrainsMono Nerd Font Mono";
      size = 9;
    };

    colors = gruvbox_dark_custom;

    bell = {
      animation = "EaseOutQuart";
      duration = 100;
      color = "0x404040";
    };

    cursor = {
      style.shape = "Beam";
      style.blinking = "Always";
      vi_mode_style = "Block";
    };

    # mouse.hide_when_typing = true;
  };
}
