{
  config,
  pkgs,
  lib,
  ...
}: {
  # application launcher
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    font = "Ubuntu Regular 14";
    terminal = lib.getExe pkgs.alacritty;
    cycle = true;
    location = "top";
    yoffset = 6;
    # theme = ./gruvbox-dark-hard.rasi;
    plugins = with pkgs; [
      rofi-calc
      (rofi-emoji.overrideAttrs (old: rec {
        version = "3.1.0";
        postFixup = ''
          chmod +x $out/share/rofi-emoji/clipboard-adapter.sh
          wrapProgram $out/share/rofi-emoji/clipboard-adapter.sh \
            --prefix PATH ':' \
              ${lib.makeBinPath (with pkgs; [libnotify wl-clipboard wtype])}
        '';
        src = fetchFromGitHub {
          owner = "Mange";
          repo = old.pname;
          rev = "v${version}";
          sha256 = "sha256-YMQG0XO6zVei6GfBdgI7jtB7px12e+xvOMxZ1QHf5kQ=";
        };
      }))
    ];
    extraConfig = {
      modi = "run,drun,calc,emoji";
    };
    theme = let
      gruvbox = {
        normal = {
          orange = "#d65d0e";
          red = "#cc241d";
          green = "#98971a";
          yellow = "#d79921";
          blue = "#458588";
          purple = "#b16286";
          aqua = "#689d6a";
          gray = "#a89984";
        };
        bright = {
          red = "#fb4934";
          green = "#b8bb26";
          yellow = "#fabd2f";
          blue = "#83a598";
          purple = "#d3869b";
          aqua = "#8ec07c";
          orange = "#fe8019";
          gray = "#928374";
        };
        bg = gruvbox.bg0;
        bg0 = "#282828";
        bg0_h = "#1d2021";
        bg0_s = "#32302f";
        bg1 = "#3c3836";
        bg2 = "#504945";
        bg3 = "#665c54";
        bg4 = "#7c6f64";
        fg = gruvbox.fg1;
        fg0 = "#fbf1c7";
        fg1 = "#ebdbb2";
        fg2 = "#d5c4a1";
        fg3 = "#bdae93";
        fg4 = "#a89984";
        inherit (gruvbox.bright) orange red green yellow blue purple aqua gray;
      };

      # Use `mkLiteral` for string-like values that should show without
      # quotes, e.g.:
      # {
      #   foo = "abc"; => foo: "abc";
      #   bar = mkLiteral "abc"; => bar: abc;
      # };
      inherit (config.lib.formats.rasi) mkLiteral;

      bgOpacity = "e5"; # 90%

      bg0 = mkLiteral (gruvbox.bg0_h + bgOpacity);
      bg1 = mkLiteral (gruvbox.bg0_s + bgOpacity);
      # selected gets no opacity
      bg2 = mkLiteral gruvbox.normal.orange;

      fg0 = mkLiteral gruvbox.fg1;
      fg1 = mkLiteral gruvbox.fg2;
      fg2 = mkLiteral gruvbox.fg3;

      font = "Ubuntu Regular";
    in {
      /*
       ******************************************************************************
      * MACOS SPOTLIGHT LIKE DARK THEME FOR ROFI
      * User                 : LR-Tech
      * Theme Repo           : https://github.com/lr-tech/rofi-themes-collection
      ******************************************************************************
      */

      "*" = {
        font = "${font} 12";

        background-color = mkLiteral "transparent";
        text-color = fg0;

        margin = mkLiteral "0";
        padding = mkLiteral "0";
        spacing = mkLiteral "0";
      };

      window = {
        background-color = bg0;

        location = mkLiteral "center";
        width = mkLiteral "640";
        y-offset = mkLiteral "-200";
        border-radius = mkLiteral "8";
      };

      inputbar = {
        font = "${font} 20";
        padding = mkLiteral "12px";
        spacing = mkLiteral "12px";
        children = mkLiteral "[ icon-search, entry ]";
      };

      icon-search = {
        expand = mkLiteral "false";
        filename = "search";
        size = mkLiteral "28px";
      };

      "icon-search, entry, element-icon, element-text" = {
        vertical-align = mkLiteral "0.5";
      };

      entry = {
        font = mkLiteral "inherit";

        placeholder = "Search";
        placeholder-color = fg2;
      };

      message = {
        border = mkLiteral "2px 0 0";
        border-color = bg1;
        background-color = bg1;
      };

      textbox = {
        padding = mkLiteral "8px 24px";
      };

      listview = {
        lines = mkLiteral "10";
        columns = mkLiteral "1";

        fixed-height = mkLiteral "false";
        border = mkLiteral "1px 0 0";
        border-color = bg1;
      };

      element = {
        padding = mkLiteral "8px 16px";
        spacing = mkLiteral "16px";
        background-color = mkLiteral "transparent";
      };

      "element normal active" = {
        text-color = bg2;
      };

      "element selected normal, element selected active" = {
        background-color = bg2;
        text-color = bg0;
      };

      element-icon = {
        size = mkLiteral "1em";
      };

      element-text = {
        text-color = mkLiteral "inherit";
      };
    };
  };
}
