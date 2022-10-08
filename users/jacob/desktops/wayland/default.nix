{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./swayidle.nix
    ./theming.nix
    ./dunst.nix
  ];

  home.packages = [
    # Lock Screen
    pkgs.swaylock-effects

    # Wallpaper
    pkgs.swaybg
  ];

  # application launcher
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    plugins = [pkgs.rofi-calc];
    font = "Ubuntu Regular 14";
    terminal = lib.getExe pkgs.alacritty;
    cycle = true;
    location = "top";
    yoffset = 6;
    # configPath = config.xdg.configHome + "rofi/theme.rasi";
    theme = let
      # Use `mkLiteral` for string-like values that should show without
      # quotes, e.g.:
      # {
      #   foo = "abc"; => foo: "abc";
      #   bar = mkLiteral "abc"; => bar: abc;
      # };
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      /*
       ******************************************************************************
      * MACOS SPOTLIGHT LIKE DARK THEME FOR ROFI
      * User                 : LR-Tech
      * Theme Repo           : https://github.com/lr-tech/rofi-themes-collection
      ******************************************************************************
      */

      "*" = {
        "font" = "Montserrat 12";

        "bg0" = mkLiteral "#242424E6";
        "bg1" = mkLiteral "#7E7E7E80";
        "bg2" = mkLiteral "#0860f2E6";

        "fg0" = mkLiteral "#DEDEDE";
        "fg1" = mkLiteral "#FFFFFF";
        "fg2" = mkLiteral "#DEDEDE80";

        "background-color" = mkLiteral "transparent";
        "text-color" = mkLiteral "@fg0";

        "margin" = mkLiteral "0";
        "padding" = mkLiteral "0";
        "spacing" = mkLiteral "0";
      };

      "window" = {
        "background-color" = mkLiteral "@bg0";

        "location" = mkLiteral "center";
        "width" = mkLiteral "640";
        "y-offset" = mkLiteral "-200";
        "border-radius" = mkLiteral "8";
      };

      "inputbar" = {
        "font" = "Montserrat 20";
        "padding" = mkLiteral "12px";
        "spacing" = mkLiteral "12px";
        "children" = mkLiteral "[ icon-search, entry ]";
      };

      "icon-search" = {
        "expand" = mkLiteral "false";
        "filename" = "search";
        "size" = mkLiteral "28px";
      };

      "icon-search, entry, element-icon, element-text" = {
        "vertical-align" = mkLiteral "0.5";
      };

      "entry" = {
        "font" = mkLiteral "inherit";

        "placeholder" = "Search";
        "placeholder-color" = mkLiteral "@fg2";
      };

      "message" = {
        "border" = mkLiteral "2px 0 0";
        "border-color" = mkLiteral "@bg1";
        "background-color" = mkLiteral "@bg1";
      };

      "textbox" = {
        "padding" = mkLiteral "8px 24px";
      };

      "listview" = {
        "lines" = mkLiteral "10";
        "columns" = mkLiteral "1";

        "fixed-height" = mkLiteral "false";
        "border" = mkLiteral "1px 0 0";
        "border-color" = mkLiteral "@bg1";
      };

      "element" = {
        "padding" = mkLiteral "8px 16px";
        "spacing" = mkLiteral "16px";
        "background-color" = mkLiteral "transparent";
      };

      "element normal active" = {
        "text-color" = mkLiteral "@bg2";
      };

      "element selected normal, element selected active" = {
        "background-color" = mkLiteral "@bg2";
        "text-color" = mkLiteral "@fg1";
      };

      "element-icon" = {
        "size" = mkLiteral "1em";
      };

      "element-text" = {
        "text-color" = mkLiteral "inherit";
      };

      #   /*
      #    ==========================================================================
      #   Rofi color theme

      #   Based on the Gruvbox color scheme for Vim by morhetz
      #   https://github.com/morhetz/gruvbox

      #   File: gruvbox-dark.rasi
      #   Desc: Gruvbox dark color theme for Rofi
      #   Author: bardisty <b@bah.im>
      #   Source: https://github.com/bardisty/gruvbox-rofi
      #   Modified: Mon Feb 12 2018 04:08:43 PST -0800
      #   ==========================================================================
      #   */

      #   "*" = {
      #     /*
      #     Theme settings
      #     */
      #     highlight = mkLiteral "bold italic";
      #     scrollbar = mkLiteral "true";

      #     /*
      #     Gruvbox dark colors
      #     */
      #     gruvbox-dark-bg0 = mkLiteral "#282828";
      #     gruvbox-dark-bg0-soft = mkLiteral "#32302f";
      #     gruvbox-dark-bg3 = mkLiteral "#665c54";
      #     gruvbox-dark-fg0 = mkLiteral "#fbf1c7";
      #     gruvbox-dark-fg1 = mkLiteral "#ebdbb2";
      #     gruvbox-dark-red-dark = mkLiteral "#cc241d";
      #     gruvbox-dark-red-light = mkLiteral "#fb4934";
      #     gruvbox-dark-yellow-dark = mkLiteral "#d79921";
      #     gruvbox-dark-yellow-light = mkLiteral "#fabd2f";
      #     gruvbox-dark-gray = mkLiteral "#a89984";

      #     /*
      #     Theme colors
      #     */
      #     background = mkLiteral "@gruvbox-dark-bg0";
      #     background-color = mkLiteral "@background";
      #     foreground = mkLiteral "@gruvbox-dark-fg1";
      #     border-color = mkLiteral "@gruvbox-dark-gray";
      #     separatorcolor = mkLiteral "@border-color";
      #     scrollbar-handle = mkLiteral "@border-color";

      #     normal-background = mkLiteral "@background";
      #     normal-foreground = mkLiteral "@foreground";
      #     alternate-normal-background = mkLiteral "@gruvbox-dark-bg0-soft";
      #     alternate-normal-foreground = mkLiteral "@foreground";
      #     selected-normal-background = mkLiteral "@gruvbox-dark-bg3";
      #     selected-normal-foreground = mkLiteral "@gruvbox-dark-fg0";

      #     active-background = mkLiteral "@gruvbox-dark-yellow-dark";
      #     active-foreground = mkLiteral "@background";
      #     alternate-active-background = mkLiteral "@active-background";
      #     alternate-active-foreground = mkLiteral "@active-foreground";
      #     selected-active-background = mkLiteral "@gruvbox-dark-yellow-light";
      #     selected-active-foreground = mkLiteral "@active-foreground";

      #     urgent-background = mkLiteral "@gruvbox-dark-red-dark";
      #     urgent-foreground = mkLiteral "@background";
      #     alternate-urgent-background = mkLiteral "@urgent-background";
      #     alternate-urgent-foreground = mkLiteral "@urgent-foreground";
      #     selected-urgent-background = mkLiteral "@gruvbox-dark-red-light";
      #     selected-urgent-foreground = mkLiteral "@urgent-foreground";
      #   };

      #   /*
      #    ==========================================================================
      #   File: gruvbox-common.rasi
      #   Desc: Shared rules between all gruvbox themes
      #   Author: bardisty <b@bah.im>
      #   Source: https://github.com/bardisty/gruvbox-rofi
      #   Modified: Mon Feb 12 2018 06:06:47 PST -0800
      #   ==========================================================================
      #   */

      #   window = {
      #     background-color = mkLiteral "@background";
      #     border = mkLiteral "2";
      #     padding = mkLiteral "2";
      #   };

      #   mainbox = {
      #     border = mkLiteral "0";
      #     padding = mkLiteral "0";
      #   };

      #   message = {
      #     border = mkLiteral "2px 0 0";
      #     border-color = mkLiteral "@separatorcolor";
      #     padding = mkLiteral "1px";
      #   };

      #   textbox = {
      #     highlight = mkLiteral "@highlight";
      #     text-color = mkLiteral "@foreground";
      #   };

      #   listview = {
      #     border = mkLiteral "2px solid 0 0";
      #     padding = mkLiteral "2px 0 0";
      #     border-color = mkLiteral "@separatorcolor";
      #     spacing = mkLiteral "2px";
      #     scrollbar = mkLiteral "@scrollbar";
      #   };

      #   element = {
      #     border = mkLiteral "0";
      #     padding = mkLiteral "2px";
      #   };

      #   "element.normal.normal" = {
      #     background-color = mkLiteral "@normal-background";
      #     text-color = mkLiteral "@normal-foreground";
      #   };

      #   "element.normal.urgent" = {
      #     background-color = mkLiteral "@urgent-background";
      #     text-color = mkLiteral "@urgent-foreground";
      #   };

      #   "element.normal.active" = {
      #     background-color = mkLiteral "@active-background";
      #     text-color = mkLiteral "@active-foreground";
      #   };

      #   "element.selected.normal" = {
      #     background-color = mkLiteral "@selected-normal-background";
      #     text-color = mkLiteral "@selected-normal-foreground";
      #   };

      #   "element.selected.urgent" = {
      #     background-color = mkLiteral "@selected-urgent-background";
      #     text-color = mkLiteral "@selected-urgent-foreground";
      #   };

      #   "element.selected.active" = {
      #     background-color = mkLiteral "@selected-active-background";
      #     text-color = mkLiteral "@selected-active-foreground";
      #   };

      #   "element.alternate.normal" = {
      #     background-color = mkLiteral "@alternate-normal-background";
      #     text-color = mkLiteral "@alternate-normal-foreground";
      #   };

      #   "element.alternate.urgent" = {
      #     background-color = mkLiteral "@alternate-urgent-background";
      #     text-color = mkLiteral "@alternate-urgent-foreground";
      #   };

      #   "element.alternate.active" = {
      #     background-color = mkLiteral "@alternate-active-background";
      #     text-color = mkLiteral "@alternate-active-foreground";
      #   };

      #   scrollbar = {
      #     width = mkLiteral "4px";
      #     border = mkLiteral "0";
      #     handle-color = mkLiteral "@scrollbar-handle";
      #     handle-width = mkLiteral "8px";
      #     padding = mkLiteral "0";
      #   };

      #   sidebar = {
      #     border = mkLiteral "2px 0 0";
      #     border-color = mkLiteral "@separatorcolor";
      #   };

      #   inputbar = {
      #     spacing = mkLiteral "0";
      #     text-color = mkLiteral "@normal-foreground";
      #     padding = mkLiteral "2px";
      #     children = mkLiteral "[ prompt, textbox-prompt-sep, entry, case-indicator ]";
      #   };

      #   "case-indicator,entry,prompt,button" = {
      #     spacing = mkLiteral "0";
      #     text-color = mkLiteral "@normal-foreground";
      #   };

      #   "button.selected" = {
      #     background-color = mkLiteral "@selected-normal-background";
      #     text-color = mkLiteral "@selected-normal-foreground";
      #   };

      #   textbox-prompt-sep = {
      #     expand = mkLiteral "false";
      #     str = ":";
      #     text-color = mkLiteral "@normal-foreground";
      #     margin = mkLiteral "0 0.3em 0 0";
      #   };
    };
  };

  # make some environment tweaks for wayland
  home.sessionVariables = {
    GDK_BACKEND = "wayland";
    # some nixpkgs modules have wrapers
    # that force electron apps to use wayland
    NIXOS_OZONE_WL = "1";
    # make qt apps expect wayland
    QT_QPA_PLATFORM = "wayland";
    # set backend for sdl
    SDL_VIDEODRIVER = "wayland";
    # fix modals from being attached on tiling wms
    _JAVA_AWT_WM_NONREPARENTING = "1";
    # firefox and mozilla software expect wayland
    MOZ_ENABLE_WAYLAND = "1";
  };
}
