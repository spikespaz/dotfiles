{ self, config, lib, pkgs, inputs, ... }: {
  imports = [
    inputs.hyprnix.homeManagerModules.hyprland
    # inputs.hyprnix.homeManagerModules.xdg-desktop-portals
    ./config.nix
    ./windowrules.nix
    ./keybinds.nix
    ./keymaps.nix
    ./waybar.nix
  ];

  home.packages = [
    # Screen Capture
    pkgs.prtsc
    # xwayland perm for pkexec
    pkgs.xorg.xhost

    pkgs.hyprpolkitagent
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    reloadConfig = true;
    systemdIntegration = true;
    recommendedEnvironment = true;

    xwayland.enable = true;

    config.exec_once = [
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
