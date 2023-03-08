pkgs: let
  maintainers = {
    spikespaz = {
      email = "jacob@birkett.dev";
      github = "spikespaz";
      githubId = "MDQ6VXNlcjEyNTAyOTg4";
      name = 12502988;
    };
  };
in {
  ja-netfilter = pkgs.callPackage ./ja-netfilter {};
  prtsc = pkgs.callPackage ./prtsc {
    inherit maintainers;
  };
  ttf-ms-win11 = pkgs.callPackage ./ttf-ms-win11 {
    inherit maintainers;
  };
  fastfetch = pkgs.callPackage ./fastfetch.nix {
    inherit maintainers;
  };
  firefox-pwa = pkgs.callPackage ./firefox-pwa.nix {
    inherit maintainers;
  };
  idlehack = pkgs.callPackage ./idlehack.nix {
    inherit maintainers;
  };
  mcpelauncher = pkgs.qt6.callPackage ./mcpelauncher.nix {};
  mcpelauncher-qt5 = pkgs.libsForQt5.callPackage ./mcpelauncher.nix {};
  plymouth-themes = pkgs.callPackage ./plymouth-themes.nix {
    inherit maintainers;
  };
  rofi-themes = pkgs.callPackage ./rofi-themes.nix {};

  obs-studio-plugins =
    pkgs.obs-studio-plugins
    // {
      advanced-scene-switcher = pkgs.qt6.callPackage ./obs-studio-plugins/advanced-scene-switcher.nix {};
      advanced-scene-switcher-qt5 = pkgs.libsForQt5.callPackage ./obs-studio-plugins/advanced-scene-switcher.nix {};
    };

  kvantum-qt6 = pkgs.callPackage ./kvantum-qt6.nix {};
  proton-ge-custom = pkgs.callPackage ./proton-ge-custom.nix {};
  qt6ct = pkgs.qt6.callPackage ./qt6ct.nix {};
}
