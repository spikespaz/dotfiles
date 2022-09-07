{ config, pkgs, dotpkgs, ... }: {
  imports = [
    ./swayidle.nix
    ./theming.nix
  ];

  home.packages = [
    # Lock Screen
    pkgs.swaylock-effects

    # Wallpaper
    pkgs.swaybg
  ];

  # application launcher
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
  };

  # make some environment tweaks for wayland
  home.sessionVariables = {
    # some nixpkgs modules have wrapers
    # that force electron apps to use wayland
    NIXOS_OZONE_WL = "1";
    # make qt apps expect wayland
    QT_QPA_PLATFORM = "wayland";
    # set backend for sdl
    SDL_VIDEODRIVER = "wayland";
    # fix modals from being attached on tiling wms
    _JAVA_AWT_WM_NONREPARENTING = "1";
    # firefox and mozilla software expect wayland
    MOZ_ENABLE_WAYLAND = "1";
  };
}
