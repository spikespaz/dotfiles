{ self, config, lib, pkgs, inputs, ... }: {
  imports = [
    inputs.hyprnix.homeManagerModules.hyprland
    # inputs.hyprnix.homeManagerModules.xdg-desktop-portals
    ./config.nix
    ./windowrules.nix
    ./keybinds.nix
    ./keymaps.nix
    ./waybar.nix
    ./default-programs.nix
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
    systemd.enable = true;
    recommendedEnvironment = true;

    xwayland.enable = true;

    config.exec_once = [
      # allow apps with risen perms after agent to connect to local xwayland
      "${lib.getExe pkgs.xorg.xhost} +local:"
    ];
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
      kdePackages.xdg-desktop-portal-kde
    ];
    configPackages = [ config.wayland.windowManager.hyprland.package ];
    config.hyprland = {
      default = [ "hyprland" "gtk" ];
      "org.freedesktop.impl.portal.FileChooser" = "kde";
      "org.freedesktop.impl.portal.Print" = "kde";
    };
  };

  wayland.windowManager.hyprland.configFile."xdph.conf".text =
    lib.generators.toHyprlang { } { # #
      screencopy.allow_token_by_default = true;
    };
}
