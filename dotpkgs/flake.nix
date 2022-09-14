{
  description = ''
    Packages used in Jacob Birkett's personal NixOS configurations.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ { self, nixpkgs, ... }: let
    inherit (nixpkgs) lib;
    genSystems = lib.genAttrs [
      "x86_64-linux"
    ];
  in with (import ./lib.nix lib); {
    packages = genSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      this = self.packages.${system};
    in mkPackages (pkgs // this) {
      maintainers = import ../maintainers.nix;
    } [
      "lapce"
      "fastfetch"
      "idlehack"
      "prtsc"
      "plymouth-themes"
    ]);

    nixosModules = mkNixosModules inputs [
      "auto-cpufreq"
    ];

    homeManagerModules = mkHmModules inputs [
      "kvantum"
      "uniform-theme"
      "idlehack"
      "randbg"
      "zsh-uncruft"
    ];
  };
}
