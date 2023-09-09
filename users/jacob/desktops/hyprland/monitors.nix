{ ... }:
let
  monitors = {
    internal = "eDP-1";
    hotplug = "HDMI-A-1";
    portable = "DP-2";
    dock = "DP-1";
  };

  # hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
in {
  wayland.windowManager.hyprland = with monitors; {
    # <https://wiki.hyprland.org/Configuring/Monitors/>
    config.monitor = [
      ", preferred, auto, 1"

      "${internal}, preferred, 1920x1080, 1"
      "${portable}, preferred, 0x1080, 1"
      "${dock}, preferred, 1920x0, 1"
      "${hotplug}, preferred, 0x1080, 1"
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
      "10".monitor = [ portable dock ];

      "11".monitor = [ hotplug internal ];
      "13".monitor = [ hotplug internal ];
      "15".monitor = [ hotplug internal ];
      "17".monitor = [ hotplug internal ];
      "19".monitor = [ hotplug internal ];

      "12".monitor = [ hotplug portable dock ];
      "14".monitor = [ hotplug portable dock ];
      "16".monitor = [ hotplug portable dock ];
      "18".monitor = [ hotplug portable dock ];
      "20".monitor = [ hotplug portable dock ];
    };

    # eventListener.handler.monitorAdd = ''
    #   ${hyprctl} dispatch moveworkspacetomonitor 2 $HL_MONITOR_NAME
    #   ${hyprctl} dispatch moveworkspacetomonitor 4 $HL_MONITOR_NAME
    #   ${hyprctl} dispatch moveworkspacetomonitor 6 $HL_MONITOR_NAME
    #   ${hyprctl} dispatch moveworkspacetomonitor 8 $HL_MONITOR_NAME
    #   ${hyprctl} dispatch moveworkspacetomonitor 10 $HL_MONITOR_NAME
    # '';
  };
}
