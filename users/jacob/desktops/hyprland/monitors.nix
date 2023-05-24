{ config, ... }:
let
  internalMon = "eDP-1";
  hotplugMon = "HDMI-A-1";
  dockMon = "DP-1";

  hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
in {
  wayland.windowManager.hyprland = {
    # <https://wiki.hyprland.org/Configuring/Monitors/>
    config.monitor = [
      # "${INTERNAL_MON}, preferred, 0x1080, 1"
      # "${DOCK_MON}, preferred, 0x0, 1"

      ", preferred, auto, 1"

      # have to use this for now,
      # need to make something using
      # <https://github.com/spikespaz/hyprshot#readme>
      "${internalMon}, preferred, 0x0, 1"
      "${hotplugMon}, preferred, 1920x0, 1"
      "${dockMon}, preferred, 1920x0, 1"

      # Causes bugs with Qt on wayland, such as menus disappearing.
      # "${INTERNAL_MON}, preferred, 1920x1080, 1"
      # "${HOTPLUG_MON}, preferred, 1920x0, 1"
      # "${DOCK_MON}, preferred, 1920x0, 1"
    ];

    workspaceRules = {
      "1".monitor = internalMon;
      "3".monitor = internalMon;
      "5".monitor = internalMon;
      "7".monitor = internalMon;
      "9".monitor = internalMon;

      "2".monitor = [ hotplugMon dockMon ];
      "4".monitor = [ hotplugMon dockMon ];
      "6".monitor = [ hotplugMon dockMon ];
      "8".monitor = [ hotplugMon dockMon ];
      "10".monitor = [ hotplugMon dockMon ];
    };

    eventListener.handler.monitorAdd = ''
      ${hyprctl} dispatch moveworkspacetomonitor 2 $HL_MONITOR_NAME
      ${hyprctl} dispatch moveworkspacetomonitor 4 $HL_MONITOR_NAME
      ${hyprctl} dispatch moveworkspacetomonitor 6 $HL_MONITOR_NAME
      ${hyprctl} dispatch moveworkspacetomonitor 8 $HL_MONITOR_NAME
      ${hyprctl} dispatch moveworkspacetomonitor 10 $HL_MONITOR_NAME
    '';
  };
}
