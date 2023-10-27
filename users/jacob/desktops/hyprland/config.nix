{ lib, ... }:
let
  rgba = rgb: a: "rgba(${lib.birdos.colors.hexRGBA' rgb a})";
  theme = lib.birdos.colors.palettes.gruvbox.dark;
  shadow = let
    # 6% of each channel
    percent = 6.0e-2;
  in lib.genAttrs [ "r" "g" "b" ] (_: builtins.floor (percent * 255));
in {
  wayland.windowManager.hyprland = {
    # <https://wiki.hyprland.org/Configuring/Variables/#general>
    config.general = {
      border_size = 2;
      gaps_inside = 5;
      gaps_outside = 10;
      active_border_color = rgba theme.fg3 1.0;
      inactive_border_color = rgba theme.bg3 1.0;
      cursor_inactive_timeout = 10;
      no_cursor_warps = true;
      resize_on_border = true;
      extend_border_grab_area = 10;
    };

    # <https://wiki.hyprland.org/Configuring/Variables/#decoration>
    config.decoration = {
      rounding = 0;
      shadow_range = 10;
      shadow_render_power = 2;
      active_shadow_color = rgba shadow 0.9;
      inactive_shadow_color = rgba shadow 0.6;
      blur = {
        size = 3; # 8
        passes = 2; # 1
        ignore_opacity = true; # false
        xray = true; # false
        noise = 6.5e-2; # 0.0117
        contrast = 0.75; # 0.8916
        brightness = 0.8; # 0.8172
      };
    };

    # <https://wiki.hyprland.org/Configuring/Variables/#input>
    config.input = let
      DISABLED = 0;
      LOOSE = 2;
    in {
      follow_mouse = LOOSE;
      float_switch_override_focus = DISABLED;

      touchpad = {
        # tap_to_click = true;
        tap_and_drag = true;
        # drag_lock = true;
      };
    };

    # <https://wiki.hyprland.org/Configuring/Variables/#binds>
    config.binds = { pass_mouse_when_bound = false; };

    config.gestures = {
      workspace_swipe = {
        enable = true;
        invert = false;
        min_speed_to_force = 20;
        cancel_ratio = 0.65;
        create_new = false;
        forever = true;
      };
    };

    # <https://wiki.hyprland.org/Configuring/Variables/#misc>
    config.misc = let FULLSCREEN_ONLY = 2;
    in {
      disable_hyprland_logo = true; # false
      disable_splash_rendering = true; # false
      force_default_wallpaper = 0; # disable weeb stuff
      variable_framerate = true;
      variable_refresh = FULLSCREEN_ONLY;
      disable_autoreload = true; # false # nix takes care of that

      # works well with swayidle
      key_press_enables_dpms = true;
      mouse_move_enables_dpms = true;
    };

    config.group = {
      insert_after_current = true;
      focus_removed_window = true;

      active_border_color = rgba theme.hl_yellow 1.0;
      inactive_border_color = rgba theme.bg3 1.0;
      locked_active_border_color = rgba theme.hl_blue 1.0;
      locked_inactive_border_color = rgba theme.bg3 1.0;

      # These features are not polished yet:
      # <https://github.com/hyprwm/Hyprland/issues/2415>
      # @MightyPlaza is working on this, but not doing it how we expect.
      # <https://github.com/hyprwm/Hyprland/pull/3197>
      groupbar = rec {
        font_size = 9;
        gradients = false;
        render_titles = true;
        scrolling = true;
        text_color = rgba theme.fg0 1.0;

        active_color = rgba theme.fg3 1.0;
        inactive_color = rgba theme.bg1 0.6;
        locked_active_color = active_color;
        locked_inactive_color = inactive_color;
      };
    };

    # <https://wiki.hyprland.org/Configuring/Dwindle-Layout/>
    config.dwindle = let ALWAYS_EAST = 2;
    in {
      force_split = ALWAYS_EAST; # 0
      preserve_split = true; # false
      # no_gaps_when_only = true;
    };

    # <https://wiki.hyprland.org/Configuring/Animations/#curves>
    animations.animation = {
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
}
