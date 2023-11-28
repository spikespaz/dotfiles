lib: {
  # INDIVIDUAL PACKAGES #

  amdctl = pkgs: _: { amdctl = pkgs.callPackage ./amdctl.nix { }; };

  ja-netfilter = pkgs: _: {
    ja-netfilter = pkgs.callPackage ./ja-netfilter { inherit lib; };
  };

  prtsc = pkgs: _: { prtsc = pkgs.callPackage ./prtsc { inherit lib; }; };

  ttf-ms-win11 = pkgs: _: {
    ttf-ms-win11 = pkgs.callPackage ./ttf-ms-win11 { inherit lib; };
  };

  fork-awesome = pkgs: _: {
    fork-awesome = pkgs.callPackage ./fork-awesome.nix { inherit lib; };
  };

  idlehack = pkgs: _: {
    idlehack = pkgs.callPackage ./idlehack.nix { inherit lib; };
  };

  proton-ge-custom = pkgs: _: {
    proton-ge-custom = pkgs.callPackage ./proton-ge-custom.nix { inherit lib; };
  };

  nerdfonts-symbols = pkgs: _: {
    nerdfonts-symbols = pkgs.callPackage ./nerdfonts-symbols { inherit lib; };
  };

  # PACKAGE SETS #

  zsh-plugins = pkgs: pkgs0: {
    zsh-plugins = pkgs.callPackage ./zsh-plugins.nix { inherit lib; };
  };
}
