lib: {
  # INDIVIDUAL PACKAGES #

  amdctl = pkgs: _: { # #
    amdctl = pkgs.callPackage ./amdctl.nix { };
  };

  ja-netfilter = pkgs: _: {
    ja-netfilter = pkgs.callPackage ./ja-netfilter { inherit lib; };
  };

  prtsc = pkgs: _: { # #
    prtsc = pkgs.callPackage ./prtsc { inherit lib; };
  };

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

  java = pkgs: _: {
    inherit (pkgs.callPackage ./java { inherit lib; })
      temurin20-jre-bin graalvm8-ce graalvm8-ce-jre;
  };

  wavefox = pkgs: _: { wavefox = pkgs.callPackage ./wavefox.nix { }; };

  discord-recolor-theme = pkgs: _: {
    discord-recolor-theme = pkgs.callPackage ./discord-recolor-theme.nix { };
  };

  noita-entangled-worlds = pkgs: _: {
    noita-entangled-worlds = pkgs.callPackage ./noita-entangled-worlds.nix { };
  };

  # PACKAGE SETS #

  zsh-plugins = pkgs: _: {
    zsh-plugins = pkgs.callPackages ./zsh-plugins.nix { inherit lib; };
  };

  firefox-extensions = pkgs: _: {
    firefox-extensions =
      pkgs.callPackages ./firefox-extensions.nix { inherit lib; };
  };

  # SCOPED PACKAGES

  platformio-python = _: pkgs0: {
    python3Packages = pkgs0.python3Packages.overrideScope
      (ps: _: { platformio = ps.callPackage ./platformio-python.nix { }; });
  };

  # SCRIPTS #

  json2nix = pkgs: _: {
    json2nix = pkgs.callPackage ./json2nix.nix { inherit lib; };
  };

  # HACKS #

  procname-shim = pkgs: _: {
    procname-shim = pkgs.callPackage ./procname-shim { };
  };
}
