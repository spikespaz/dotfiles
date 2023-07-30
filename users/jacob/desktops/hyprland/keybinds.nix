# Converted with regex from hyprland config
# search: ^(\s*)(bind[rwelm]*) = (|\w+), (|\$?\w+), (.+)$ /gm
# replace: $1$2."$3, $4" = "$5";

{ config, pkgs, lib, ... }: {
  # for now until I get the module working
  # xdg.configFile."hypr/hyprland.conf".text =
  #   lib.mkOrder 1200 (builtins.readFile ./keybinds.conf);

  # <https://wiki.hyprland.org/Configuring/Dispatchers/>
  wayland.windowManager.hyprland.keyBinds = let
    MOUSE_LMB = "mouse:272";
    MOUSE_RMB = "mouse:273";
    MOUSE_MMB = "mouse:274";
    MOUSE_EX1 = "mouse:275";
    MOUSE_EX2 = "mouse:276";

    INTERNAL_MON = "eDP-1";
    HOTPLUG_MON = "HDMI-A-1";
    DOCK_MON = "DP-1";

    playerctl = lib.getExe pkgs.playerctl;
    slight = lib.getExe pkgs.slight;
    osdFunc = lib.getExe config.utilities.osd-functions.package;
    activateCleanMode = "disable-input-devices-notify";
    pinWindow = (pkgs.writeShellScript "pin-window" (let
      hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
    in ''
      if ${hyprctl} activewindow | grep 'floating: 0'; then
      	${hyprctl} dispatch togglefloating active;
      fi

      ${hyprctl} dispatch pin active
    '')).outPath;
  in {
    #########################
    ### PROGRAM LAUNCHING ###
    #########################

    bind."SUPER, Space" = "exec, rofi -show drun -show-icons";
    bind."SUPER, R" = "exec, rofi -show run";

    #####################
    ### FUNCTION KEYS ###
    #####################

    # <https://github.com/xkbcommon/libxkbcommon/blob/master/include/xkbcommon/xkbcommon-keysyms.h>

    # toggle mute default sink
    bindl.", XF86AudioMute" = "exec, ${osdFunc} output mute";

    # raise and lower default sink
    bindel.", XF86AudioRaiseVolume" = "exec, ${osdFunc} output +0.05";
    bindel.", XF86AudioLowerVolume" = "exec, ${osdFunc} output -0.05";

    # mute default source
    bindl.", XF86AudioMicMute" = "exec, ${osdFunc} input mute";

    # raise and lower display brightness
    bindel.", XF86MonBrightnessUp" = "exec, ${slight} inc 10 -t 300ms";
    bindel.", XF86MonBrightnessDown" = "exec, ${slight} dec 10 -t 300ms";

    # lock the screen and then turn off dpms (actually toggle for emergency usage)
    # does not work because (r)elease only works for individual keys, not combos
    # issue when using Fn + XF96Display
    # sleep is added to compensate, but not perfect solution
    # Fn is XF86WakeUp
    bindrl.", XF86Display" =
      "exec, loginctl lock-session && sleep 5 && hyprctl dispatch dpms toggle";

    ##################
    ### MEDIA KEYS ###
    ##################

    # my laptop does not have dedicated media keys, sadness
    bindl."SUPER, slash" = "exec, ${playerctl} play-pause";
    bindl."SUPER, comma" = "exec, ${playerctl} previous";
    bindl."SUPER, period" = "exec, ${playerctl} next";

    ##########################
    ### ESSENTIAL PROGRAMS ###
    ##########################

    bind."SUPER, E" = "exec, dolphin";
    bind."SUPER, T" = "exec, alacritty";
    bind."SUPER, C" = "exec, qalculate-gtk";

    ####################
    ### WINDOW FOCUS ###
    ####################

    bind."SUPER, left" = "movefocus, l";
    bind."SUPER, right" = "movefocus, r";
    bind."SUPER, up" = "movefocus, u";
    bind."SUPER, down" = "movefocus, d";

    ###########################
    ### WORKSPACE SWITCHING ###
    ###########################

    # TODO
    # how does the special workspace work?
    # fn + f12 (star)
    # XF86WakeUp (Fn),
    # bind = , XF86Favorites, workspace, special
    # bind = SUPER, XF86Favorites, movetoworkspace, special

    # RELATIVE

    bind."SUPER, mouse_up" = "workspace, m+1";
    bind."SUPER, mouse_down" = "workspace, m-1";

    bind."SUPER, page_down" = "workspace, m+1";
    bind."SUPER, page_up" = "workspace, m-1";

    # NUMBERED

    bind."SUPER, 1" = "workspace, 1";
    bind."SUPER, 2" = "workspace, 2";
    bind."SUPER, 3" = "workspace, 3";
    bind."SUPER, 4" = "workspace, 4";
    bind."SUPER, 5" = "workspace, 5";
    bind."SUPER, 6" = "workspace, 6";
    bind."SUPER, 7" = "workspace, 7";
    bind."SUPER, 8" = "workspace, 8";
    bind."SUPER, 9" = "workspace, 9";
    bind."SUPER, 0" = "workspace, 10";

    ##################################
    ### INTERPANEL WINDOW MOVEMENT ###
    ##################################

    # POSITION

    bindm."SUPER, ${MOUSE_LMB}" = "movewindow";
    #bindm = , $MOUSE_MMB, movewindow
    bindm."SUPER, ${MOUSE_RMB}" = "resizewindow";

    bindm.", ${MOUSE_EX2}" = "movewindow";
    bindm.", ${MOUSE_EX1}" = "resizewindow";

    bind."SUPER_SHIFT, left" = "movewindow, l";
    bind."SUPER_SHIFT, right" = "movewindow, r";
    bind."SUPER_SHIFT, up" = "movewindow, u";
    bind."SUPER_SHIFT, down" = "movewindow, d";

    # RESIZING

    bind."SUPER, backslash" = "submap, resize";
    submap.resize = {
      binde.", right" = "resizeactive, 10 0";
      binde.", left" = "resizeactive, -10 0";
      binde.", up" = "resizeactive, 0 -10";
      binde.", down" = "resizeactive, 0 10";

      binde."SHIFT, right" = "resizeactive, 30 0";
      binde."SHIFT, left" = "resizeactive, -30 0";
      binde."SHIFT, up" = "resizeactive, 0 -30";
      binde."SHIFT, down" = "resizeactive, 0 30";
      bind.", escape" = "submap, reset";
      bind."CTRL, C" = "submap, reset";
      # submap = reset
    };

    ######################################
    ### TRANSWORKSPACE WINDOW MOVEMENT ###
    ######################################

    # RELATIVE

    bind."SUPER_SHIFT, page_down" = "movetoworkspace, m+1";
    bind."SUPER_SHIFT, page_up" = "movetoworkspace, m-1";

    bind."SUPER_SHIFT, mouse_up" = "movetoworkspace, m+1";
    bind."SUPER_SHIFT, mouse_down" = "movetoworkspace, m-1";

    bind."SUPER, ${MOUSE_EX2}" = "movetoworkspace, m+1";
    bind."SUPER, ${MOUSE_EX1}" = "movetoworkspace, m-1";

    # NUMBERED

    bind."SUPER_SHIFT, 1" = "movetoworkspacesilent, 1";
    bind."SUPER_SHIFT, 2" = "movetoworkspacesilent, 2";
    bind."SUPER_SHIFT, 3" = "movetoworkspacesilent, 3";
    bind."SUPER_SHIFT, 4" = "movetoworkspacesilent, 4";
    bind."SUPER_SHIFT, 5" = "movetoworkspacesilent, 5";
    bind."SUPER_SHIFT, 6" = "movetoworkspacesilent, 6";
    bind."SUPER_SHIFT, 7" = "movetoworkspacesilent, 7";
    bind."SUPER_SHIFT, 8" = "movetoworkspacesilent, 8";
    bind."SUPER_SHIFT, 9" = "movetoworkspacesilent, 9";
    bind."SUPER_SHIFT, 0" = "movetoworkspacesilent, 10";

    #####################
    ### ACTIVE WINDOW ###
    #####################

    bind."SUPER, Q" = "killactive,";
    bind."SUPER, F" = "togglefloating,";
    bind."SUPER, P" = "exec, ${pinWindow}";
    #bind = SUPER, P, pseudo,
    bind."SUPER_SHIFT, F" = "fullscreen, 0";
    bind."ALT, grave" = "changegroupactive, f";
    bind."ALT, tab" = "changegroupactive, b";
    bind."SUPER, grave" = "togglesplit,";
    bind."SUPER, tab" = "togglegroup,";

    #####################
    ### MISCELLANEOUS ###
    #####################

    # Swap the two active workspaces
    bind."SUPER_SHIFT, S" = "swapactiveworkspaces, ${INTERNAL_MON} ${DOCK_MON}";

    # Dismiss all dunst notifications
    bind."SUPER_ALT, N" = "exec, dunstctl close-all";
    # Lock the session immediately
    bind."SUPER, l" = "exec, loginctl lock-session";
    # Force exit window manager
    bind."SUPER_SHIFT, M" = "exit,";
    # Force kill PID by surface selection
    bind."SUPER_SHIFT, Q" = "exec, hyprctl kill";
    # Screenshot to file by monitor selection
    bind."SUPER, print" = "exec, prtsc -m m -D -b 00000066";
    # Screenshot to clipboard by region selection
    bind."SUPER_SHIFT, print" = "exec, prtsc -c -m r -D -b 00000066";
    # Rofi-emoji
    bind."SUPER, equals" = "exec, rofi -show emoji -emoji-mode copy";
    # "Cleaning mode"
    bindrl."SUPER_CTRL_SHIFT, delete" = "exec, ${activateCleanMode}";

    # Passthrough all shortcuts
    bind."SUPER_SHIFT, K" = "submap, passthru";
    submap.passthru = {
      bind."SUPER_SHIFT, K" = "submap, reset";
      # submap = reset
    };
  };
}
