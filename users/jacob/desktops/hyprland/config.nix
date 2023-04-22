{
  wayland.windowManager.hyprland = let
    internalMon = "eDP-1";
    hotplugMon = "HDMI-A-1";
    dockMon = "DP-1";
  in {
    # <https://wiki.hyprland.org/Configuring/Variables/#general>
    config.general = {
      border_size = 2;
      gaps_inside = 5;
      gaps_outside = 10;
      active_border_color = "rgba(BDAE93FF)";
      inactive_border_color = "rgba(665C54FF)";
      cursor_inactive_timeout = 10;
      no_cursor_warps = true;
    };

    # <https://wiki.hyprland.org/Configuring/Variables/#decoration>
    config.decoration = {
      rounding = 0;
      blur_size = 2;
      blur_passes = 3;
      blur_ignore_opacity = true;
      blur_new_optimizations = true;
      shadow_range = 10;
      shadow_render_power = 2;
      active_shadow_color = "rgba(0F0F0FE6)";
      inactive_shadow_color = "rgba(0F0F0F99)";
    };

    # <https://wiki.hyprland.org/Configuring/Variables/#input>
    config.input = {
      follow_mouse = "loose";
      float_switch_override_focus = "disabled"; # float_to_float

      touchpad = {
        tap_to_click = false;
      };
    };

    config.gestures = {
      workspace_swipe = {
        enable = true;
        invert = false;
        min_speed_to_force = 20;
        cancel_ratio = 0.65;
        create_new = false;
      };
    };

    # <https://wiki.hyprland.org/Configuring/Variables/#misc>
    config.misc = {
      disable_hyprland_logo = true; # false
      disable_splash_rendering = true; # false
      no_vfr = false; # true
      disable_autoreload = true; # false # nix takes care of that
      enable_swallow = true; # false
    };

    # <https://wiki.hyprland.org/Configuring/Dwindle-Layout/>
    config.dwindle = {
      active_group_border_color = "0xFF8ec07c"; # aqua
      inactive_group_border_color = "0xFF665c54"; # bg3
      force_split = 2; # 0
      preserve_split = true; # false
      no_gaps_when_only = true; # false
    };

    ################
    ### DISPLAYS ###
    ################

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

    config.blurls = [
      "rofi"
      "notifications"
    ];

    # <https://wiki.hyprland.org/Configuring/Animations/#curves>
    animations = {
      enable = true;
      animation = {
        # window creation
        windowsIn = {
          enable = true;
          duration = 200;
          curve = "easeOutCirc";
          style = "popin 60%";
        };
        fadeIn = {
          enable = true;
          duration = 100;
          curve = "easeOutCirc";
        };
        # window destruction
        windowsOut = {
          enable = true;
          duration = 200;
          curve = "easeOutCirc";
          style = "popin 60%";
        };
        fadeOut = {
          enable = true;
          duration = 100;
          curve = "easeOutCirc";
        };
        # window movement
        windowsMove = {
          enable = true;
          duration = 300;
          curve = "easeInOutCubic";
          style = "popin";
        };
        workspaces = {
          enable = true;
          duration = 200;
          curve = "easeOutCirc";
          style = "slide";
        };
      };
    };
  };
}
