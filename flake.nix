{
  description = ''
    A Nix flake for reproducing the Linux system configurations used on
    Jacob Birkett's personal computers.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";

    hyprland.url = "github:hyprwm/hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";

    nil.url = "github:oxalica/nil";
    nil.inputs.nixpkgs.follows = "nixpkgs";

    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";

    webcord.url = "github:fufexan/webcord-flake";
    webcord.inputs.nixpkgs.follows = "nixpkgs";

    homeage.url = "github:spikespaz/homeage?ref=fix-bin-paths";
    homeage.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    nur,
    ...
  }: let
    system = "x86_64-linux";

    inherit (nixpkgs) lib;
    flib = import ./lib.nix lib;

    inputPackageOverlays = flib.mkPackagesOverlay system (
      removeAttrs inputs [
        "nixpkgs"
        "nur"
      ]
    );
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        inputPackageOverlays
        nur.overlay
        self.overlays.${system}.allowUnfree
        self.overlays.${system}.nixpkgsFixes
      ];
    };
    # manually import the packages subflake to avoid locking issues
    # this flake must have the same inputs that dotpkgs expects
    dotpkgs = (import ./dotpkgs/flake.nix).outputs inputs;
  in {
    # merge the packages flake into this one
    inherit (dotpkgs) packages overlays nixosModules homeManagerModules;

    nixosConfigurations =
      flib.genConfigurations ./systems {
        inherit self nixpkgs pkgs;
        modules = flib.joinNixosModules inputs;
      } [
        "jacob-thinkpad"
      ];

    homeConfigurations =
      flib.genConfigurations ./users {
        inherit self home-manager pkgs;
        ulib = import ./users/lib.nix lib;
        hmModules = flib.joinHomeModules inputs;
      } [
        "jacob"
      ];
  };
}
