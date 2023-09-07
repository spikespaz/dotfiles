{ config, ... }:
let
  monitors = {
    internal = "eDP-1";
    hotplug = "HDMI-A-1";
    portable = "DP-2";
    dock = "DP-1";
  };

  hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
in {
  wayland.windowManager.hyprland = with monitors; {
    # <https://wiki.hyprland.org/Configuring/Monitors/>
    config.monitor = [
      # "${INTERNAL_MON}, preferred, 0x1080, 1"
      # "${DOCK_MON}, preferred, 0x0, 1"

      ", preferred, auto, 1"

      # have to use this for now,
      # need to make something using
      # <https://github.com/spikespaz/hyprshot#readme>
      "${internal}, preferred, 0x0, 1"
      "${hotplug}, preferred, 1920x0, 1"
      "${portable}, preferred, 1920x0, 1"
      "${dock}, preferred, 1920x0, 1"

      # Causes bugs with Qt on wayland, such as menus disappearing.
      # "${INTERNAL_MON}, preferred, 1920x1080, 1"
      # "${HOTPLUG_MON}, preferred, 1920x0, 1"
      # "${DOCK_MON}, preferred, 1920x0, 1"
    ];

    workspaceRules = with monitors; {
      "1".monitor = internal;
      "3".monitor = internal;
      "5".monitor = internal;
      "7".monitor = internal;
      "9".monitor = internal;

      "2".monitor = [ portable dock ];
      "4".monitor = [ portable dock ];
      "6".monitor = [ portable dock ];
      "8".monitor = [ portable dock ];
      "10".monitor = [ hotplug portable dock ];
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
