pkgs: pkgs0: {
  # Individual packages

  ja-netfilter = pkgs.callPackage ./ja-netfilter { };
  prtsc = pkgs.callPackage ./prtsc { };
  ttf-ms-win11 = pkgs.callPackage ./ttf-ms-win11 { };
  fork-awesome = pkgs.callPackage ./fork-awesome.nix { };
  idlehack = pkgs.callPackage ./idlehack.nix { };
  proton-ge-custom = pkgs.callPackage ./proton-ge-custom.nix { };
  nerdfonts-symbols = pkgs.callPackage ./nerdfonts.nix { };

  # Package sets

  zsh-plugins = pkgs.callPackage ./zsh-plugins.nix { };
}
