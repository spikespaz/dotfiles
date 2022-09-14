{
  description = ''
    Packages used in Jacob Birkett's personal NixOS configurations.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs @ { self, nixpkgs, ... }: let
    inherit (nixpkgs) lib;
    genSystems = lib.genAttrs [
      "x86_64-linux"
    ];
    importsWith = inputs: builtins.mapAttrs (_: v: import v inputs);
  in {
    packages = genSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in builtins.mapAttrs (_: v: pkgs.callPackage v {}) {
      fastfetch = ./fastfetch/package.nix;
      idlehack = ./idlehack/package.nix;
      prtsc = ./prtsc/package.nix;
      plymouth-themes = ./plymouth-themes/package.nix;
    });

    nixosModules = importsWith inputs {
      auto-cpufreq = ./auto-cpufreq/module.nix;
    };

    homeManagerModules = importsWith inputs {
      kvantum = ./kvantum/hm-module.nix;
      uniform-theme = ./uniform-theme/hm-module.nix;
      idlehack = ./idlehack/hm-module.nix;
      randbg = ./randbg/hm-module.nix;
      zsh-uncruft = ./zsh-uncruft/hm-module.nix;
    };
  };
}
