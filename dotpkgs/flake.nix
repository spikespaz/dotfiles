{
  description = ''
    Packages used in Jacob Birkett's personal NixOS configurations.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ { self, nixpkgs, ... }: let
    inherit (nixpkgs) lib;
    flib = import ./lib.nix lib;

    genSystems = lib.genAttrs [
      "x86_64-linux"
    ];
  in {
    packages = genSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      this = self.packages.${system};
    in flib.mkPackages (pkgs // this) {
      maintainers = import ./maintainers.nix;
    } [
      "ttf-ms-win11"
      "lapce"
      "fastfetch"
      "idlehack"
      "prtsc"
      "plymouth-themes"
    ]);

    overlays = genSystems (system: let
      pkgs = self.packages.${system};
    in {
      allPackages = (_: _: self.packages.${system});
      allowUnfree = (_: _: {
        ttf-ms-win11 = pkgs.ttf-ms-win11.overrideAttrs (old:
          lib.recursiveUpdate old { meta.license.free = true; }
        );
      });
    });

    nixosModules = flib.mkNixosModules inputs [
      "auto-cpufreq"
    ];

    homeManagerModules = flib.mkHmModules inputs [
      "kvantum"
      "uniform-theme"
      "idlehack"
      "randbg"
      "zsh-uncruft"
    ];
  };
}
