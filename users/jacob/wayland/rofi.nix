{ config, pkgs, lib, ... }: {
  # application launcher
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    font = "Ubuntu Regular 14";
    terminal = lib.getExe pkgs.alacritty;
    cycle = true;
    location = "top";
    yoffset = 6;
    extraConfig = {
      # modes = "run,drun,emoji";
      icon-theme = config.gtk.iconTheme.name;
    };
    # theme = ./gruvbox-dark-hard.rasi;
    plugins = with pkgs; [
      rofi-calc
      (rofi-emoji.overrideAttrs {
        postFixup = ''
          chmod +x $out/share/rofi-emoji/clipboard-adapter.sh
          wrapProgram $out/share/rofi-emoji/clipboard-adapter.sh \
            --prefix PATH ':' \
              ${lib.makeBinPath (with pkgs; [ libnotify wl-clipboard wtype ])}
        '';
      })
    ];
    theme = let
      # Use `mkLiteral` for string-like values that should show without
      # quotes, e.g.:
      # {
      #   foo = "abc"; => foo: "abc";
      #   bar = mkLiteral "abc"; => bar: abc;
      # };
      inherit (config.lib.formats.rasi) mkLiteral;

      inherit (lib.birdos.colors) hexRGBA';
      mkColorLiteral = rgb: a: mkLiteral (hexRGBA' rgb a);
      gb = (lib.birdos.colors.formats.custom mkColorLiteral).gruvbox.dark;

      font = "Ubuntu Regular";
      accent = gb.hl_orange;
    in {
      #*****************************************************************************
      # MACOS SPOTLIGHT LIKE DARK THEME FOR ROFI
      # User                 : LR-Tech
      # Theme Repo           : https://github.com/lr-tech/rofi-themes-collection
      #*****************************************************************************

      "*" = {
        font = "${font} 12";

        background-color = mkLiteral "transparent";
        text-color = gb.fg0 1.0;

        margin = mkLiteral "0";
        padding = mkLiteral "0";
        spacing = mkLiteral "0";
      };

      window = {
        background-color = gb.bg0_hard 0.9;

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
        placeholder-color = gb.fg3 1.0;
      };

      message = {
        border = mkLiteral "2px 0 0";
        border-color = gb.bg0_soft 0.9;
        background-color = gb.bg0_soft 0.9;
      };

      textbox = { padding = mkLiteral "8px 24px"; };

      listview = {
        lines = mkLiteral "10";
        columns = mkLiteral "1";

        fixed-height = mkLiteral "false";
        border = mkLiteral "1px 0 0";
        border-color = gb.bg0_soft 0.9;
      };

      element = {
        padding = mkLiteral "8px 16px";
        spacing = mkLiteral "16px";
        background-color = mkLiteral "transparent";
      };

      "element normal active" = { text-color = accent 1.0; };

      "element selected normal, element selected active" = {
        background-color = accent 1.0;
        text-color = gb.bg0_hard 0.9;
      };

      element-icon = { size = mkLiteral "1em"; };

      element-text = { text-color = mkLiteral "inherit"; };
    };
  };
}
