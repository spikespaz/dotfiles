{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixos-hardware, home-manager, ... }: {
    nixosConfigurations = {
      jacob-thinkpad = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./system/filesystems.nix
          ./system/configuration.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-p14s-amd-gen2
        ];
      };
    };
    homeConfigurations = {
      jacob = home-manager.lib {
        modules = [
          ./users/jacob/profile.nix
        ];
      };
    };
  };
}
