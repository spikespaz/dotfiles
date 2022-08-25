{ pkgs, ... }: {
  home.username = "jacob";
  home.homeDirectory = "/home/jacob";

  home.packages = with pkgs; [
    # Diagnostics
    wev
    neofetch

    # Email
    thunderbird
    # Messaging
    discord
    neochat
    # Text Editors
    vscode

    # Office Suite
    onlyoffice-bin

    # Desktop Theming
    papirus-icon-theme
    materia-theme
    materia-kde-theme
    libsForQt5.qtstyleplugin-kvantum
  ];

  xdg.configFile."hypr/hyprland.conf".text = ''
    monitor = eDP-1,preferred,1920x1080,1
    monitor = DP-1,preferred,1920x0,1
    monitor = ,preferred,auto,1
    workspace = eDP-1,1
    workspace = DP-1,2

    general {
      #sensitivity = 1.0
      #apply_sens_to_raw = false
      #main_mod = SUPER
      border_size = 2
      #no_border_on_floating = false
      gaps_in = 5
      gaps_out = 10
      col.active_border = 0xFF929292
      col.inactive_border = 0xFF373737
      cursor_inactive_timeout = 10
      #damage_tracking = full
      no_cursor_warps = true
    }

    decoration {
      rounding = 3
      #multisample_edges = true
      #active_opacity = 1.0
      #inactive_opacity = 1.0
      #fullscreen_opacity = 1.0
      #blur = true
      #blur_size = 8
      #blur_passes = 1
      #blur_ignore_opacity = false
      blur_new_optimizations = 1
      drop_shadow = false
      #shadow_range = 4
      #shadow_render_power = 3
      #shadow_ignore_window = true
      #col.shadow = 0xEE1A1A1A
      #shadow_offset = 0 0
    }

    animations {
      #enabled = 1
      animation = windows,1,7,default
      animation = border,1,10,default
      animation = fade,1,10,default
      animation = workspaces,1,6,default
    }

    input {
      #kb_layout = us
      #kb_variant =
      #kb_model =
      #kb_options =
      #kb_rules =
      #kb_file =
      follow_mouse = 2
      float_switch_override_focus = false
      #repeat_rate = 25
      #repeat_delay = 600
      #natural_scroll = false
      #numlock_by_default = false
      #force_no_accel = false
      #sensitivity = 0.0

      touchpad {
        #disable_while_typing = true
        #natural_scroll = false
        #clickfinger_behavior = false
        #middle_button_emulation = false
        tap-to-click = false
      }
    }

    gestures {
      workspace_swipe = true
      #workspace_swipe_fingers = 3
      #workspace_swipe_distance = 300
      workspace_swipe_invert = false
      workspace_swipe_min_speed_to_force = 10
      #workspace_swipe_cancel_ratio = 0.5
    }

    misc {
      disable_hyprland_logo = true
      #disable_splash_rendering = false
      no_vfr = false # variable refresh
      #damage_entire_on_snapshot = false
      #mouse_move_enables_dpms = false
      #always_follow_on_dnd = true
      #layers_hog_keyboard_focus = true
      #animate_manual_resizes = false
    }

    binds {
      #pass_mouse_when_bound = true
      #scroll_event_delay = 300
      workspace_back_and_forth = true
      #allow_workspace_cycles = false
    }

    dwindle {
      #pseudotile = 0
    }

    # example window rules
    # for windows named/classed as abc and xyz
    #windowrule=move 69 420,abc
    #windowrule=size 420 69,abc
    #windowrule=tile,xyz
    #windowrule=float,abc
    #windowrule=pseudo,abc
    #windowrule=monitor 0,xyz

    #########################
    ### PROGRAM LAUNCHING ###
    #########################

    bind = SUPER,Space,exec,rofi -show drun
    bind = SUPER,R,exec,rofi -show run

    ##########################
    ### ESSENTIAL PROGRAMS ###
    ##########################

    bind = SUPER,E,exec,dolphin
    bind = SUPER,T,exec,alacritty

    ####################
    ### WINDOW FOCUS ###
    ####################

    bind = SUPER,left,movefocus,l
    bind = SUPER,right,movefocus,r
    bind = SUPER,up,movefocus,u
    bind = SUPER,down,movefocus,d

    ###########################
    ### WORKSPACE SWITCHING ###
    ###########################

    # RELATIVE

    bind = SUPER,page_down,workspace,m+1
    bind = SUPER,page_up,workspace,m-1

    bind = SUPER,mouse_up,workspace,m+1
    bind = SUPER,mouse_down,workspace,m-1

    # NUMBERED

    bind = SUPER,1,workspace,1
    bind = SUPER,2,workspace,2
    bind = SUPER,3,workspace,3
    bind = SUPER,4,workspace,4
    bind = SUPER,5,workspace,5
    bind = SUPER,6,workspace,6
    bind = SUPER,7,workspace,7
    bind = SUPER,8,workspace,8
    bind = SUPER,9,workspace,9
    bind = SUPER,0,workspace,10

    #############################
    ### WINDOW PANEL MOVEMENT ###
    #############################

    bind = ALT,left,movewindow,l
    bind = ALT,right,movewindow,r
    bind = ALT,up,movewindow,u
    bind = ALT,down,movewindow,d

    #################################
    ### WINDOW WORKSPACE MOVEMENT ###
    #################################

    # RELATIVE

    bind = ALT,page_down,movetoworkspace,m+1
    bind = ALT,page_up,movetoworkspace,m-1

    bind = ALT,mouse_up,movetoworkspace,m+1
    bind = ALT,mouse_down,movetoworkspace,m-1

    # NUMBERED

    # these used to be `movetoworkspacesilent` but it is buggy
    bind = ALT,1,movetoworkspace,1
    bind = ALT,2,movetoworkspace,2
    bind = ALT,3,movetoworkspace,3
    bind = ALT,4,movetoworkspace,4
    bind = ALT,5,movetoworkspace,5
    bind = ALT,6,movetoworkspace,6
    bind = ALT,7,movetoworkspace,7
    bind = ALT,8,movetoworkspace,8
    bind = ALT,9,movetoworkspace,9
    bind = ALT,0,movetoworkspace,10

    #####################
    ### ACTIVE WINDOW ###
    #####################

    bind = SUPER,Q,killactive,
    bind = SUPER,F,togglefloating,
    bind = SUPER,P,pseudo,
    #bind = SUPER,F,fullscreen,1 # very buggy

    #####################
    ### MISCELLANEOUS ###
    #####################

    bind = SUPER,M,exit,

    # can't hide the presses from applications
    #bind = ,mouse:275,movetoworkspace,m+1
    #bind = ,mouse:276,movetoworkspace,m-1
  '';

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Jacob Birkett";
    userEmail = "jacob@birkett.dev";

    delta.enable = true;
  };

  programs.bat = {
    enable = true;
  };

  programs.exa = {
    enable = true;
  };

  programs.lsd = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
  };

  programs.firefox = {
    enable = true;
  };

  programs.chromium = {
    enable = true;
  };

  programs.helix = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
  };

  programs.hexchat = {
    enable = true;
  };

  programs.obs-studio = {
    enable = true;
  };

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
  };

  home.stateVersion = "22.05";
}
