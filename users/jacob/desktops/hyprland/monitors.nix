{ ... }:
let
  monitors = {
    internal = "eDP-1";
    portable = "DP-2";
    dock = "DP-1";
    hotplug = "HDMI-A-1";
  };
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

    # Unfortunately, fallbacks do not work.
    #
    # I had expected to be able to do something like
    # `"20".monitor = [ hotplug portable dock ];` to have the workspace
    # assigned to a monitor depending on what is connected.
    #
    # The way that it is right now, when monitors are missing I believe
    # the workspace positions are indeterminate, which is unfortunate.
    #
    # Eventually, I will solve this problem by completing
    # <https://github.com/spikespaz/hyprland-workspace-profiles>.
    #
    # Such a feature has been explicitly declined for inclusion in Hyprland.
    workspaceRules = with monitors; {
      "1".monitor = internal;
      "3".monitor = internal;
      "5".monitor = internal;
      "7".monitor = internal;
      "9".monitor = internal;

      "2".monitor = dock;
      "4".monitor = dock;
      "6".monitor = dock;
      "8".monitor = dock;
      "10".monitor = dock;

      "11".monitor = hotplug;
      "13".monitor = hotplug;
      "15".monitor = hotplug;
      "17".monitor = hotplug;
      "19".monitor = hotplug;

      "12".monitor = portable;
      "14".monitor = portable;
      "16".monitor = portable;
      "18".monitor = portable;
      "20".monitor = portable;
    };
  };
}
