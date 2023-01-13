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
        "workspaces"
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
    };
  };
}
