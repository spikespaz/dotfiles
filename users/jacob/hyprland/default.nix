{ self, config, lib, pkgs, inputs, ... }: {
  imports = [
    inputs.hyprland-nix.homeManagerModules.hyprland
    # inputs.hyprland-nix.homeManagerModules.xdg-desktop-portals
    ./config.nix
    ./windowrules.nix
    ./keybinds.nix
    ./waybar.nix
  ];

  home.packages = [
    # Screen Capture
    pkgs.prtsc
    # xwayland perm for pkexec
    pkgs.xorg.xhost
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    reloadConfig = true;
    systemdIntegration = true;
    recommendedEnvironment = true;

    xwayland.enable = true;

    config.exec_once = [
      # polkit agent, raises to root access with gui
      "${lib.getExe pkgs.lxqt.lxqt-policykit}"
      # allow apps with risen perms after agent to connect to local xwayland
      "${lib.getExe pkgs.xorg.xhost} +local:"
    ];
  };

  # xdg.desktopPortals = {
  #   enable = true;
  #   extraPortals = [
  #     pkgs.xdg-desktop-portal-hyprland
  #     pkgs.xdg-desktop-portal-kde
  #     pkgs.xdg-desktop-portal-gtk
  #   ];
  #   configPackages = [ config.wayland.windowManager.hyprland.package ];
  #   config = {
  #     x-cinnamon = { default = [ "xapp" "gtk" ]; };
  #     pantheon = {
  #       default = [ "pantheon" "gtk" ];
  #       "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
  #     };
  #     common = { default = [ "gtk" ]; };
  #   };
  # };
}
