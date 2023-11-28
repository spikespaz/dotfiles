{ lib, system, nixpkgs }:
let
  packageOverlays = builtins.attrValues (import ./overlays.nix lib);
  pkgs = import nixpkgs {
    localSystem = system;
    overlays = packageOverlays;
  };
in lib.updates [
  # INDIVIDUAL PACKAGES #

  (with pkgs; {
    inherit amdctl ja-netfilter prtsc ttf-ms-win11 fork-awesome idlehack
      proton-ge-custom nerdfonts-symbols;
  })

  # PACKAGE SETS #

  (with pkgs.zsh-plugins; {
    zsh-autosuggestions = zsh-autosuggestions;
    zsh-autocomplete = zsh-autocomplete;
    zsh-edit = zsh-edit;
    zsh-autopair = zsh-autopair;
    zsh-auto-notify = zsh-auto-notify;
    zsh-window-title = zsh-window-title;
    zsh-fast-syntax-highlighting = zsh-fast-syntax-highlighting;
  })
]
