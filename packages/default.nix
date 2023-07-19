final: prev: {
  # Individual packages

  ja-netfilter = final.callPackage ./ja-netfilter { };
  prtsc = final.callPackage ./prtsc { };
  ttf-ms-win11 = final.callPackage ./ttf-ms-win11 { };
  fastfetch = final.callPackage ./fastfetch.nix { };
  fork-awesome = final.callPackage ./fork-awesome.nix { };
  idlehack = final.callPackage ./idlehack.nix { };
  plymouth-themes = final.callPackage ./plymouth-themes.nix { };
  proton-ge-custom = final.callPackage ./proton-ge-custom.nix { };
  qt6ct = final.qt6.callPackage ./qt6ct.nix { };
  nerdfonts-symbols-only = final.callPackage ./nerdfonts.nix { };

  # Package sets

  obs-studio-plugins = prev.obs-studio-plugins // {
    advanced-scene-switcher =
      final.qt6.callPackage ./obs-studio-plugins/advanced-scene-switcher.nix
      { };
    advanced-scene-switcher-qt5 = final.libsForQt5.callPackage
      ./obs-studio-plugins/advanced-scene-switcher.nix { };
  };
}
