{
  self,
  config,
  lib,
  pkgs,
  # hmModules,
  inputs,
  ...
}: {
  imports = [
    inputs.hyprland.homeManagerModules.default
    self.homeManagerModules.desktop-portals
    self.homeManagerModules.hyprland
    ./config.nix
    ./events.nix
    ./windowrules.nix
    ./keybinds.nix
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
    enableConfig = true;
    # reloadConfig = false;
    systemdIntegration = true;
    recommendedEnvironment = true;

    xwayland.enable = true;
    xwayland.hidpi = false;

    extraInitConfig.exec_once = [
      # polkit agent, raises to root access with gui
      "${lib.getExe pkgs.lxqt.lxqt-policykit}"
      # allow apps with risen perms after agent to connect to local xwayland
      "${lib.getExe pkgs.xorg.xhost} +local:"
    ];
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
