{
  description = "Packages used in Jacob Birkett's personal NixOS configurations.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, ... }: let
    inherit (nixpkgs) lib;
    genSystems = lib.genAttrs [
      "x86_64-linux"
    ];
  in {
    packages = genSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      fastfetch = pkgs.callPackage ./fastfetch {};
      idlehack = pkgs.callPackage ./idlehack {};
      prtsc = pkgs.callPackage ./prtsc {};
      plymouth-themes = pkgs.callPackage ./plymouth-themes {};
    });

    nixosModules = {
      auto-cpufreq = import ./auto-cpufreq/module.nix;
    };

    homeManagerModules = {
      uniform-theme = import ./uniform-theme/hm-module.nix;
      idlehack = import ./idlehack/hm-module.nix self;
      randbg = import ./randbg/hm-module.nix self;
      zsh-uncruft = import ./zsh-uncruft/hm-module.nix self;
    };
  };
}
