pkgs: pkgs0: {
  # Individual packages

  ja-netfilter = pkgs.callPackage ./ja-netfilter { };
  prtsc = pkgs.callPackage ./prtsc { };
  ttf-ms-win11 = pkgs.callPackage ./ttf-ms-win11 { };
  fastfetch = pkgs.callPackage ./fastfetch.nix { };
  fork-awesome = pkgs.callPackage ./fork-awesome.nix { };
  idlehack = pkgs.callPackage ./idlehack.nix { };
  proton-ge-custom = pkgs.callPackage ./proton-ge-custom.nix { };
  qt6ct = pkgs.qt6.callPackage ./qt6ct.nix { };
  nerdfonts-symbols = pkgs.callPackage ./nerdfonts.nix { };

  # Package sets

  zsh-plugins = pkgs.callPackage ./zsh-plugins.nix { };
  obs-studio-plugins = pkgs0.obs-studio-plugins // {
    advanced-scene-switcher =
      pkgs.qt6.callPackage ./obs-studio-plugins/advanced-scene-switcher.nix { };
    advanced-scene-switcher-qt5 = pkgs.libsForQt5.callPackage
      ./obs-studio-plugins/advanced-scene-switcher.nix { };
  };
}
