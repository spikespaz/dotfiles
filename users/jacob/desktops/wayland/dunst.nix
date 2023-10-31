{ config, lib, pkgs, ... }: {
  home.packages = [ pkgs.libnotify ];

  services.dunst = {
    enable = true;

    waylandDisplay = "wayland-0";

    iconTheme.name = "Papirus-Dark";
    iconTheme.package = pkgs.papirus-icon-theme;
    iconTheme.size = "32x32";

    settings = let
      gb = lib.birdos.colors.formats.hexRGBA'.gruvbox.dark;

      bg_a = 0.8;
      fg_a = 0.9;
      background = gb.bg0 bg_a;
      foreground = gb.fg0 fg_a;
      highlight = gb.hl_blue fg_a;
      urgency_low = gb.hl_purple fg_a;
      urgency_normal = gb.fg3 fg_a;
      urgency_critical = gb.hl_yellow fg_a;
    in {
      global = {
        # position
        layer = "overlay";
        # monitor = 1;
        follow = "mouse";
        origin = "top-right";
        offset = "6x32";

        # limits
        notification-limit = 7;
        indicate_hidden = true;
        idle_threshold = "1m";
        sticky_history = 20;

        # appearance
        frame_width = 2;
        corner_radius = 5;
        width = "(250, 350)";
        height = 150;
        gap_size = 6;
        inherit background foreground;

        # progress
        highlight = highlight;
        progress_bar_height = 20;
        progress_bar_min_width = 250;
        progress_bar_max_width = 350;
        progress_bar_frame_width = 2;

        # text
        font = "Ubuntu Regular 9";
        markup = "full";
        line_height = 4;
        padding = 12;
        format = "<b>%s</b>\\n%b\\n<small><i>%a</i></small>";

        # icon
        vertical_alignment = "top";

        # actions
        mouse_left_click = "do_action";
        mouse_right_click = "close_current";
        mouse_middle_click = "context";
        dmenu = "${lib.getExe config.programs.rofi.package} -dmenu -p dunst";
      };

      urgency_low = {
        frame_color = urgency_low;
        timeout = "7s";
      };

      urgency_normal = {
        frame_color = urgency_normal;
        timeout = "7s";
      };

      urgency_critical = {
        frame_color = urgency_critical;
        timeout = "15s";
      };
    };
  };
}
