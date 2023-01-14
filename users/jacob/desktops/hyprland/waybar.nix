{
  lib,
  pkgs,
  ...
}: let
  compileSCSS = name: source: "${pkgs.runCommandLocal name {} ''
    mkdir -p $out
    ${lib.getExe pkgs.sassc} -t expanded '${source}' > $out/${name}.css
  ''}/${name}.css";
in {
  programs.waybar.enable = true;
  programs.waybar.package = pkgs.symlinkJoin {
    name = "waybar";
    paths = [pkgs.waybar-hyprland pkgs.material-design-icons];
  };
  programs.waybar.systemd.enable = true;
  programs.waybar.style =
    builtins.readFile (compileSCSS "waybar-style" ./waybar.scss);
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
        "clock#time"
        "clock#date"
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

      "clock#time" = {
        format = "{:%I:%M %p}";
      };

      "clock#date" = {
        format = "{:%A, %B %d}";
      };

      ## MODULES-RIGHT ##

      backlight = {};

      network = {
        format-ethernet = "󰈀";
        format-wifi = "{icon} {essid}";
        format-linked = "󱫱";
        format-disconnected = "󰲛";
        format-icons = ["󰤟" "󰤢" "󰤥" "󰤨"];
        tooltip-format = ''
          <b>Interface</b>: {ifname}
          <b>Address:</b> {ipaddr}
          <b>Netmask:</b> {netmask}
          <b>Gateway:</b> {gwaddr}
          <b>Speeds:</b> {bandwidthUpBytes} UL, {bandwidthDownBytes} DL
        '';
        tooltip-format-wifi = ''
          <b>SSID:</b> {essid}
          <b>Strength:</b> {signaldBm} ({signalStrength})
          <b>Frequency:</b> {frequency}
          <b>Address:</b> {ipaddr}
          <b>Netmask:</b> {netmask}
          <b>Gateway:</b> {gwaddr}
          <b>Speeds:</b> {bandwidthUpBytes} UL, {bandwidthDownBytes} DL
        '';
        tooltip-format-disconnected = "Network disconnected.";
      };

      bluetooth = {};

      battery = {
        interval = 5;
        bat = "BAT0";
        full-at = 94;
        format = "{icon} {capacity}%";
        format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
        states = {
          battery-10 = 10;
          battery-20 = 20;
          battery-30 = 30;
          battery-40 = 40;
          battery-50 = 50;
          battery-60 = 60;
          battery-70 = 70;
          battery-80 = 80;
          battery-90 = 90;
          battery-100 = 100;
        };
        format-notcharging = "󰚥 AC";
        format-charging-battery-10 = "󰢜 {capacity}%";
        format-charging-battery-20 = "󰂆 {capacity}%";
        format-charging-battery-30 = "󰂇 {capacity}%";
        format-charging-battery-40 = "󰂈 {capacity}%";
        format-charging-battery-50 = "󰢝 {capacity}%";
        format-charging-battery-60 = "󰂉 {capacity}%";
        format-charging-battery-70 = "󰢞 {capacity}%";
        format-charging-battery-80 = "󰂊 {capacity}%";
        format-charging-battery-90 = "󰂋 {capacity}%";
        format-charging-battery-100 = "󰂅 {capacity}%";
      };

      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = "󰈈";
          deactivated = "󱎫";
        };
        tooltip-format-activated = "Idle timer inhibited, device will not sleep.";
        tooltop-format-deactivated = "Idle timer enabled, device will sleep when not in use.";
      };
    };
  };
}
