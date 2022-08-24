# <https://github.com/MatthiasBenaets/nixos-config>
# <https://github.com/NobbZ/nixos-config>
#####
# <https://github.com/nix-community/impermanence>
{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/hyprland/v0.11.1beta";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { nixpkgs, nixos-hardware, home-manager, hyprland, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;

        config.allowUnfree = true;
      };
#       pkgs = nixpkgs.legacyPackages.${system};
    in
  {
    nixosConfigurations = {
      jacob-thinkpad = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./system/filesystems.nix
          ./system/configuration.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-p14s-amd-gen2
        ];
      };
    };
    homeConfigurations = {
      jacob = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          (import ./users/jacob/profile.nix inputs)
        ];
      };
    };
  };
}
