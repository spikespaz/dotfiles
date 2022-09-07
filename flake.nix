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
    nixpkgs,
    nixos-hardware,
    home-manager,
    hyprland,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    dotpkgs = (import ./packages/flake.nix).outputs inputs;
  in {
    # dotpkgs is not used as a subflake because there
    # are locking issues with subflakes, and this works fine
    inherit (dotpkgs) packages homeManagerModules;

    nixosConfigurations = {
      jacob-thinkpad = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          nixos-hardware.nixosModules.lenovo-thinkpad-p14s-amd-gen2
          ./system/filesystems.nix
          ./system/configuration.nix
          ./system/powersave.nix
          ./system/greeter.nix
        ];

        specialArgs = {
          inherit inputs;
          inherit dotpkgs;
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

        extraSpecialArgs = {
          inherit inputs;
          inherit dotpkgs;
        };
      };
    };
  };
}
