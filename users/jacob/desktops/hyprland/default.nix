{
  lib,
  pkgs,
  hmModules,
  ...
}: {
  imports = [hmModules.hyprland];

  home.packages = [
    # Screen Capture
    pkgs.prtsc

    # xwayland perm for pxexec
    pkgs.xorg.xhost
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    recommendedEnvironment = true;

    xwayland = {
      enable = true;
      hidpi = false;
    };

    extraInitConfig = ''
      # polkit agent, raises to root access with gui
      exec-once = ${lib.getExe pkgs.lxqt.lxqt-policykit}
      # allow apps with risen perms after agent to connect to local xwayland
      exec-once = ${lib.getExe pkgs.xorg.xhost} +local:
    '';

    # <https://wiki.hyprland.org/Configuring/Variables/#general>
    config.general = {
      # sensitivity = 1.0;
      border_size = 2;
      # no_border_on_floating = false;
      gaps_inside = 6;
      gaps_outside = 12;
      active_border_color = "0xFFBDAE93";
      inactive_border_color = "0xFF665C54";
      cursor_inactive_timeout = 10;
      # damage_tracking = "full";
      # layout = "dwindle";
      no_cursor_warps = true;
      # apply_sens_to_raw = false;
    };

    # <https://wiki.hyprland.org/Configuring/Variables/#decoration>
    config.decoration = {
      rounding = 0;
      # multisample_edges = true;
      # active_opacity = 1.0;
      # inactive_opacity = 1.0;
      # fullscreen_opacity = 1.0;
      # blur = true;
      blur_size = 2;
      blur_passes = 3;
      blur_ignore_opacity = true;
      blur_new_optimizations = true;
      # drop_shadow = true;
      shadow_range = 10;
      shadow_render_power = 2;
      # shadow_ignore_window = true;
      shadow_color = "0xE60F0F0F";
      shadow_inactive_color = "0x990F0F0F";
      # shadow_offset = 0 0;
      # dim_inactive = false;
      # dim_strength = 0.5;
    };

    # <https://wiki.hyprland.org/Configuring/Animations/#curves>
    config.animations = {
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
      };
    };

    config.input = {
      # kb_layout = us;
      # kb_variant = null;
      # kb_model = null;
      # kb_options = null;
      # kb_rules = null;
      # kb_file = null;
      follow_mouse = 2;
      float_switch_override_focus = 2;
      # repeat_rate = 25;
      # repeat_delay = 600;
      # natural_scroll = false;
      # numlock_by_default = false;
      # force_no_accel = false;
      # sensitivity = 0.0;
      # left_handed = false;
      # accel_profile = "adaptive";
      # scroll_method = "2fg";

      touchpad = {
        # disable_while_typing = true;
        # natural_scroll = false;
        # clickfinger_behavior = false;
        # middle_button_emulation = false;
        tap_to_click = false;
        # drag_lock = false;
        # scroll_factor = 1.0;
      };
    };

    config.gestures = {
      workspace_swipe = {
        enable = true;
        # fingers = 3;
        # distance = 300;
        invert = false;
        min_speed_to_force = 20;
        cancel_ratio = 0.65;
      };
    };

    # <https://wiki.hyprland.org/Configuring/Variables/#misc>
    config.misc = {
      disable_hyprland_logo = true; # false
      disable_splash_rendering = true; # false
      no_vfr = false; # true
      # damage_entire_on_snapshot = false;
      # mouse_move_enables_dpms = false;
      # always_follow_on_dnd = true;
      # layers_hog_keyboard_focus = true;
      # animate_manual_resizes = false;
      disable_autoreload = true; # false # nix takes care of that;
      enable_swallow = true; # false
      swallow_regex = "^(Alacritty|dolphin|Steam)$"; # [EMPTY]
    };

    # <https://wiki.hyprland.org/Configuring/Variables/#binds>
    config.binds = {
      # pass_mouse_when_bound = false;
      # scroll_event_delay = 300; # TODO play with this
      # workspace_back_and_forth = false;
      # allow_workspace_cycles = false;
    };

    # <https://wiki.hyprland.org/Configuring/Dwindle-Layout/>
    config.dwindle = {
      # pseudotile = false;
      # group_border_color = 0x66777700;
      # group_border_color = 0x66777700;
      # group_border_active_color = 0x66FFFF00;
      # group_border_active_color = 0x66FFFF00;
      force_split = 2; # 0
      preserve_split = true; # false
      # special_scale_factor = 0.8;
      # split_width_multiplier = 1.0;
      no_gaps_when_only = true; # false
      # use_active_for_splits = true;
    };

    # <https://wiki.hyprland.org/Configuring/Variables/#debug>
    config.debug = {
      # overlay = false;
      # damage_blink = false;
      # disable_logs = false;
      # disable_time = false;
    };

    # prepend the config with more exec lines,
    # for starting swayidle
    extraConfig = (
      builtins.replaceStrings [
        "%FUNCTIONS%"
      ] [
        (lib.getExe (pkgs.keyboard-functions.override {
          scriptOptions = {
            # to get it to the top of the list
            urgency = "critical";
            outputMaximum = 1.25;
            colors.normalHighlight = "#458588e6";
            colors.warningHighlight = "#cc241de6";
          };
        }))
      ]
      (lib.concatStringsSep "\n\n" [
        # hyprland config, split up
        (builtins.readFile ./displays.conf)
        (builtins.readFile ./keybinds.conf)
        (builtins.readFile ./windowrules.conf)
      ])
    );
  };
}
