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
      idlehack = pkgs.callPackage ./idlehack {};
    });

    homeManagerModules = {
      idlehack = import ./idlehack/hm-module.nix self;
      randbg = import ./randbg/hm-module.nix self;
    };
  };
}