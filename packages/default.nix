final: prev: {
  ja-netfilter = final.callPackage ./ja-netfilter { };
  prtsc = final.callPackage ./prtsc { };
  ttf-ms-win11 = final.callPackage ./ttf-ms-win11 { };
  fastfetch = final.callPackage ./fastfetch.nix { };
  firefox-pwa = final.callPackage ./firefox-pwa.nix { };
  idlehack = final.callPackage ./idlehack.nix { };
  mcpelauncher = final.qt6.callPackage ./mcpelauncher.nix { };
  mcpelauncher-qt5 = final.libsForQt5.callPackage ./mcpelauncher.nix { };
  plymouth-themes = final.callPackage ./plymouth-themes.nix { };
  rofi-themes = final.callPackage ./rofi-themes.nix { };

  obs-studio-plugins = prev.obs-studio-plugins // {
    advanced-scene-switcher =
      final.qt6.callPackage ./obs-studio-plugins/advanced-scene-switcher.nix
      { };
    advanced-scene-switcher-qt5 = final.libsForQt5.callPackage
      ./obs-studio-plugins/advanced-scene-switcher.nix { };
  };

  kvantum-qt6 = final.callPackage ./kvantum-qt6.nix { };
  proton-ge-custom = final.callPackage ./proton-ge-custom.nix { };
  qt6ct = final.qt6.callPackage ./qt6ct.nix { };
}
