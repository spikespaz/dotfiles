{
  self,
  config,
  lib,
  pkgs,
  hmModules,
  ...
}: {
  imports = [
    hmModules.hyprland
    self.homeManagerModules.hyprland-events
    self.homeManagerModules.desktop-portals
    ./config.nix
    ./events.nix
    ./windowrules.nix
    ./waybar.nix
    # ./eww
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
        "%DISABLE_INPUT_DEVICES%"
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
        (lib.getExe config.utilities.osd-functions.package)
        # DISABLE_INPUT_DEVICES
        # TODO probably should make this a package again, with overrides
        # like the above. Or make it a module that provides an overridden
        # package as a read-only option.
        "disable-input-devices-notify"
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
        package = pkgs.xdg-desktop-portal-hyprland;
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
