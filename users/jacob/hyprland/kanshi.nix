{ config, lib, ... }:
let
  mkOutput = name: args: {
    inherit name;
    config = {
      criteria = name;
      status = "enable";
      mode = null;
      position = null;
      scale = 1.0;
      transform = "normal";
    } // args;
  };

  internalMonitor = mkOutput "eDP-1" { };
  externalMonitor = mkOutput "HDMI-A-1" { };
  dockedMonitor = mkOutput "DP-1" {
    criteria = "Ancor Communications Inc ASUS VH238 B6LMIZ000302";
  };

  hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
in {
  wayland.windowManager.hyprland.config.monitor = [
    # internal monitor (assumes 1080p)
    "${internalMonitor.name}, 1920x1080, 0x0, 1"
    # default for other monitors (assumes 1080p mon to the left)
    ", preferred, 1920x0, 1"
  ];

  wayland.windowManager.hyprland.config.wsbind =
    let mapWsBind = wss: mon: map (ws: "${mon}, ${toString ws}") wss;
    in lib.concatLists [
      # assign odd numbered workspaces to internal monitor
      (mapWsBind [ 1 3 5 7 9 ] internalMonitor.name)
      # assign evens to the external monitor
      (mapWsBind [ 2 4 6 8 10 ] dockedMonitor.name)
      (mapWsBind [ 2 4 6 8 10 ] externalMonitor.name)
    ];

  # <https://man.archlinux.org/man/kanshi.5.en>keepa
  services.kanshi = let
    reloadWaybar = "systemctl --user reload waybar.service";
    moveWorkspace = ws: mon:
      "${hyprctl} dispatch moveworkspacetomonitor '${toString ws}' '${mon}'";
    moveWorkspaces = wss: mon: map (ws: moveWorkspace ws mon) wss;
  in {
    enable = true;
    systemdTarget = "graphical-session.target";

    profiles."default" = {
      exec = [ reloadWaybar ];
      outputs = [ (internalMonitor.config // { position = "0,0"; }) ];
    };

    profiles."docked-vertical" = {
      exec = [ reloadWaybar ]
        ++ (moveWorkspaces [ 2 4 6 8 10 ] dockedMonitor.name);
      outputs = [
        (dockedMonitor.config // { position = "0,0"; })
        (internalMonitor.config // { position = "0,1080"; })
      ];
    };

    profiles."external-horizontal" = {
      exec = [ reloadWaybar ]
        ++ (moveWorkspaces [ 2 4 6 8 10 ] externalMonitor.name);
      outputs = [
        (internalMonitor.config // { position = "0,0"; })
        (externalMonitor.config // { position = "1920,0"; })
      ];
    };
  };
}
