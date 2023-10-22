{ self, config, lib, pkgs, inputs, ... }: {
  imports = [
    self.homeManagerModules.desktop-portals
    inputs.hyprland-nix.homeManagerModules.default
    ./config.nix
    ./monitors.nix
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

  xdg.desktopPortals = {
    xdgOpenUsePortal = true;
    enable = true;
    portals = let useIn = [ "Hyprland" ];
    in {
      hyprland = {
        package = pkgs.xdg-desktop-portal-hyprland;
        inherit useIn;
      };
      kde = {
        package = pkgs.libsForQt5.xdg-desktop-portal-kde;
        interfaces = [ "org.freedesktop.impl.portal.FileChooser" ];
        inherit useIn;
      };
    };
  };
}
