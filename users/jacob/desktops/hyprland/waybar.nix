{pkgs, ...}: {
  programs.waybar.enable = true;
  programs.waybar.package = pkgs.waybar-hyprland;
  programs.waybar.systemd.enable = true;
  programs.waybar.settings = {
    mainBar = {
      layer = "top";
      position = "top";
      mode = "dock";
      height = 26;

      modules-left = [
        "wlr/workspaces"
        "hyprland/window"
      ];

      modules-center = [
        "clock"
      ];

      modules-right = [
        "backlight"
        "network"
        "bluetooth"
        "battery"
      ];

      ## MODULES-LEFT ##

      "wlr/workspaces" = {};

      "hyprland/window" = {};

      ## MODULES-CENTER ##

      clock = {
        format = "{:%I:%M %p - %a, %b %d}";
      };

      ## MODULES-RIGHT ##

      backlight = {};

      network = {};

      bluetooth = {};

      battery = {};
    };
  };
}
