{
  description = ''
    A Nix flake for reproducing the Linux system configurations used on
    Jacob Birkett's personal computers.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";

    nil.url = "github:oxalica/nil";
    nil.inputs.nixpkgs.follows = "nixpkgs";

    webcord.url = "github:fufexan/webcord-flake";
    webcord.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    ...
  }: let
    system = "x86_64-linux";

    inherit (nixpkgs) lib;
    flib = import ./lib.nix lib;

    inputPackageOverlays = flib.mkPackagesOverlay system (
      removeAttrs inputs [
        "nixpkgs"
      ]
    );
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        inputPackageOverlays
        self.overlays.${system}.allowUnfree
        (_: prev: {
          lxqt = prev.lxqt.overrideScope' (_: prev: {
            lxqt-policykit = (prev.lxqt-policykit.overrideAttrs (old: {
              # this one needs to be a pull request
              meta = old.meta // { mainProgram = "lxqt-policykit-agent"; };
            }));
          });
        })
      ];
    };
    # manually import the packages subflake to avoid locking issues
    # this flake must have the same inputs that dotpkgs expects
    dotpkgs = (import ./dotpkgs/flake.nix).outputs inputs;
  in {
    # merge the packages flake into this one
    inherit (dotpkgs) packages overlays nixosModules homeManagerModules;

    nixosConfigurations = flib.genSystemConfigurations {
      inherit nixpkgs pkgs;
      modules = flib.joinNixosModules inputs;
    } [
      "jacob-thinkpad"
    ];

    homeConfigurations = flib.genUserConfigurations {
      inherit home-manager pkgs;
      ulib = import ./users/lib.nix lib;
      hmModules = flib.joinHomeModules inputs;
    } [
      "jacob"
    ];
  };
}
