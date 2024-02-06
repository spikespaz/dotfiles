# The monitor and workspace positions are entirely dependent upon the order of
# which I plug in the displays. The portable monitor has to be plugged in
# with Thunderbolt before connecting the laptop to the dock.
# If the portable monitor isn't connected to the dock before the laptop,
# it will switch DP-5 and DP-6.
#
# TODO: Look into at a feature addition for Hyprland where
# monitor descriptions can be matched.
# Also could be fixed in HLWSP.
#
{ lib, pkgs, config, ... }:
let
  hyprctl =
    lib.getExe' config.wayland.windowManager.hyprland.finalPackage "hyprctl";

  origin = {
    x = 0;
    y = 0;
  };
  inherit (config.wayland.windowManager.hyprland.monitors)
    portable internal desk-dock default;
in {
  wayland.windowManager.hyprland = {
    monitors = {
      # The laptop is on an incline, positioned directly beneath the
      # monitor affixed to my desk.
      # The internal Samsung display (for ThinkPad P14s) is 3.8k 16:10 OLED.
      # scaled to a virtual size of 1920x1080.
      internal = {
        name = "eDP-1";
        resolution.x = 2880;
        resolution.y = 1800;
        scale = 1.5;
        # There is a portable monitor sometimes plugged in to my lower-left.
        position.x = portable.position.x + builtins.floor portable.size.x;
        position.y = desk-dock.position.y + builtins.floor desk-dock.size.y;
        refreshRate = 90;
        bitdepth = 10;
      };

      # I have a 2k 16:9 monitor on a mount at head level, directly forward.
      desk-dock = {
        name = "DP-5";
        resolution.x = 2560;
        resolution.y = 1440;
        # Align it directly above the internal monitor,
        # overhanging the portable monitor underneath to the left.
        position.x = builtins.floor
          ( # Middle X coordinate of the internal monitor,
            (internal.position.x + internal.size.x / 2)
            # subtracted by half the scaled width of this monitor.
            - desk-dock.size.x / 2);
        position.y = origin.y;
        refreshRate = 165;
        bitdepth = 10;
      };

      # The portable monitor is on my lower-left,
      # just under the bottom corner of the desk monitor
      # and adjacent left of the internal one.
      portable = {
        name = "DP-6";
        resolution.x = 1920;
        resolution.y = 1080;
        position.x = origin.x;
        position.y = desk-dock.position.y + builtins.floor desk-dock.size.y;
        bitdepth = 10;
      };

      # Any other random monitors (for example HDMI, or portable on DP-1)
      # should assume a position to the right of the internal display.
      default = {
        name = "";
        resolution = "preferred";
        position.x = builtins.floor (internal.position.x + internal.size.x);
        position.y = internal.position.y;
      };
    };

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
    workspaceRules = {
      "1".monitor = internal.name;
      "3".monitor = internal.name;
      "5".monitor = internal.name;
      "7".monitor = internal.name;
      "9".monitor = internal.name;

      "2".monitor = desk-dock.name;
      "4".monitor = desk-dock.name;
      "6".monitor = desk-dock.name;
      "8".monitor = desk-dock.name;
      "10".monitor = desk-dock.name;

      "11".monitor = portable.name;
      "13".monitor = portable.name;
      "15".monitor = portable.name;
      "17".monitor = portable.name;
      "19".monitor = portable.name;

      # "12".monitor = hotplug.name;
      # "14".monitor = hotplug.name;
      # "16".monitor = hotplug.name;
      # "18".monitor = hotplug.name;
      # "20".monitor = hotplug.name;

    };

    # This is here to fix a Hyprland bug that seems to persist (repeat regression).
    # When a monitor is connected, all workspaces assigned to it will be moved.
    # Hyprland should already do that, but for some reason, it misses some.
    eventListener.handler.monitorAdd =
      lib.pipe config.wayland.windowManager.hyprland.workspaceRules [
        (lib.mapAttrsToList (ws: attrs: {
          inherit ws;
          mon = attrs.monitor;
        }))
        (lib.groupBy' (wss: attrs: wss ++ [ attrs.ws ]) [ ] (attrs: attrs.mon))
        (lib.mapAttrsToList (mon: wss: ''
          if [[ "$HL_MONITOR_NAME" = '${mon}' ]]; then
            ${
              lib.concatStringsSep "\n  " (map (ws:
                "${hyprctl} dispatch moveworkspacetomonitor '${ws}' '${mon}'")
                wss)
            }
          fi
        ''))
        lib.concatLines
      ];
  };
}
