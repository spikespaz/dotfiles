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

    config.wsbind = [
      "1, ${internalMon}"
      "3, ${internalMon}"
      "5, ${internalMon}"
      "7, ${internalMon}"
      "9, ${internalMon}"

      "2, ${hotplugMon}"
      "4, ${hotplugMon}"
      "6, ${hotplugMon}"
      "8, ${hotplugMon}"
      "10, ${hotplugMon}"

      "2, ${dockMon}"
      "4, ${dockMon}"
      "6, ${dockMon}"
      "8, ${dockMon}"
      "10, ${dockMon}"
    ];

    eventListener.handler.monitorAdd = ''
      ${hyprctl} dispatch moveworkspacetomonitor 2 $HL_MONITOR_NAME
      ${hyprctl} dispatch moveworkspacetomonitor 4 $HL_MONITOR_NAME
      ${hyprctl} dispatch moveworkspacetomonitor 6 $HL_MONITOR_NAME
      ${hyprctl} dispatch moveworkspacetomonitor 8 $HL_MONITOR_NAME
      ${hyprctl} dispatch moveworkspacetomonitor 10 $HL_MONITOR_NAME
    '';
  };
}
