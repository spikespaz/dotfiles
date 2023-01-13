{pkgs, ...}: {
  programs.waybar.enable = true;
  programs.waybar.package = pkgs.symlinkJoin {
    name = "waybar";
    paths = [pkgs.waybar-hyprland pkgs.material-design-icons];
  };
  programs.waybar.systemd.enable = true;
  programs.waybar.style = ./waybar.css;
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
        "idle_inhibitor"
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

      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = "󱎬";
          deactivated = "󱎫";
        };
      };
    };
  };
}
