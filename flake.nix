{
  description = ''
    A Nix flake for reproducing the Linux system configurations used on
    Jacob Birkett's personal computers.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:nixos/nixos-hardware";

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
    nixos-hardware,
    home-manager,
    ...
  }: let
    system = "x86_64-linux";
    allowUnfree = true;

    inherit (nixpkgs) lib;
    flib = import ./lib.nix lib;

    pkgs = nixpkgs.legacyPackages.${system};
    # manually import the packages subflake to avoid locking issues
    # this flake must have the same inputs that dotpkgs expects
    dotpkgs = (import ./dotpkgs/flake.nix).outputs inputs;
  in flib.spoofAllowUnfree allowUnfree {
    # merge the packages flake into this one
    inherit (dotpkgs) packages nixosModules homeManagerModules;

    nixosConfigurations = {
      jacob-thinkpad = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          nixos-hardware.nixosModules.lenovo-thinkpad-p14s-amd-gen2
          ./system/filesystems.nix
          ./system/configuration.nix
          ./system/powersave.nix
          ./system/touchpad.nix
          ./system/greeter.nix
        ];

        specialArgs = flib.flatFlakes system {
          dotpkgs = self;
        };
      };
    };

    homeConfigurations = {
      jacob = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = let
          desktops = import ./users/jacob/desktops;
        in [
          ./users/jacob/profile.nix
	        desktops.hyprland
	        desktops.software
        ];

        extraSpecialArgs = flib.flatFlakes system {
          dotpkgs = self;
          hyprland = inputs.hyprland;
          nil = inputs.nil;
          webcord = inputs.webcord;
        };
      };
    };
  };
}
