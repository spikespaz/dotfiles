{
  wayland.windowManager.hyprland = {
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
    config.input = let
      DISABLED = 0;
      LOOSE = 2;
    in {
      follow_mouse = LOOSE;
      float_switch_override_focus = DISABLED;

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
    config.misc = let
      FULLSCREEN_ONLY = 2;
    in {
      disable_hyprland_logo = true; # false
      disable_splash_rendering = true; # false
      no_vfr = false; # true
      disable_autoreload = true; # false # nix takes care of that
      enable_swallow = true; # false
    };

    # <https://wiki.hyprland.org/Configuring/Dwindle-Layout/>
    config.dwindle = let
      ALWAYS_EAST = 2;
    in {
      active_group_border_color = "0xFF8ec07c"; # aqua
      inactive_group_border_color = "0xFF665c54"; # bg3
      force_split = ALWAYS_EAST; # 0
      preserve_split = true; # false
      no_gaps_when_only = true; # false
    };

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
