{
  flake,
  lib,
  pkgs,
  hmModules,
  ...
}: {
  imports = [
    hmModules.hyprland
    flake.modules.desktop-portals
    ./config.nix
    ./windowrules.nix
  ];

  home.packages = [
    # Screen Capture
    pkgs.prtsc

    # xwayland perm for pkexec
    pkgs.xorg.xhost
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    recommendedEnvironment = true;

    xwayland.enable = true;
    xwayland.hidpi = false;

    extraInitConfig = ''
      # polkit agent, raises to root access with gui
      exec-once = ${lib.getExe pkgs.lxqt.lxqt-policykit}
      # allow apps with risen perms after agent to connect to local xwayland
      exec-once = ${lib.getExe pkgs.xorg.xhost} +local:
    '';

    # prepend the config with more exec lines,
    # for starting swayidle
    extraConfig = (
      builtins.replaceStrings [
        "%PIN_WINDOW_SCRIPT%"
        "%FUNCTIONS%"
      ] [
        # PIN_WINDOW_SCRIPT
        "${pkgs.writeShellScript "pin-window" (let
          hyprctl = "${pkgs.hyprland}/bin/hyprctl";
        in ''
          if ${hyprctl} activewindow | grep 'floating: 0'; then
          	${hyprctl} dispatch togglefloating active;
          fi

          ${hyprctl} dispatch pin active
        '')}"
        # FUNCTIONS
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
        ''
          blurls = rofi
          blurls = notifications
        ''
        # hyprland config, split up
        (builtins.readFile ./displays.conf)
        (builtins.readFile ./keybinds.conf)
      ])
    );
  };

  xdg.desktopPortals = {
    enable = true;
    portals = let
      useIn = ["Hyprland"];
    in [
      {
        package = pkgs.xdg-desktop-portal-wlr;
        inherit useIn;
      }
      {
        package = pkgs.libsForQt5.xdg-desktop-portal-kde;
        interfaces = [
          # "org.freedesktop.impl.portal.Access"
          # "org.freedesktop.impl.portal.Account"
          # "org.freedesktop.impl.portal.AppChooser"
          # "org.freedesktop.impl.portal.Background"
          # "org.freedesktop.impl.portal.Email"
          "org.freedesktop.impl.portal.FileChooser"
          # "org.freedesktop.impl.portal.Inhibit"
          # "org.freedesktop.impl.portal.Notification"
          # "org.freedesktop.impl.portal.Print"
          # "org.freedesktop.impl.portal.ScreenCast"
          # "org.freedesktop.impl.portal.Screenshot"
          # "org.freedesktop.impl.portal.RemoteDesktop"
          # "org.freedesktop.impl.portal.Settings"
        ];
        inherit useIn;
      }
    ];
  };
}
