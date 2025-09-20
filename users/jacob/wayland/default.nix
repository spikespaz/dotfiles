{ config, pkgs, lib, ... }: {
  imports = [
    ./timeouts.nix
    ./swaylock.nix
    ./wlogout.nix
    ./gui-theme.nix
    ./dunst.nix
    ./rofi.nix
    ./utilities.nix
    ./gammastep.nix
  ];

  home.packages = [
    # Wallpaper
    pkgs.swaybg
  ];

  # make some environment tweaks for wayland
  home.sessionVariables = let b = b: if b then "1" else "0";
  in {
    GDK_BACKEND = "wayland,x11";
    # some nixpkgs modules have wrapers
    # that force electron apps to use wayland
    NIXOS_OZONE_WL = b true;
    # make qt apps expect wayland
    QT_QPA_PLATFORM = "wayland";
    # set backend for sdl
    SDL_VIDEODRIVER = "wayland";
    # fix modals from being attached on tiling wms
    _JAVA_AWT_WM_NONREPARENTING = b true;
    # fix java gui antialiasing
    _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd";
    # firefox and mozilla software expect wayland
    MOZ_ENABLE_WAYLAND = b true;
  };
}
