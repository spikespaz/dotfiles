# <https://github.com/MatthiasBenaets/nixos-config>
# <https://github.com/NobbZ/nixos-config>
#####
# <https://github.com/nix-community/impermanence>
{
  description = ''
    A Nix flake for reproducing the Linux system on
    Jacob Birkett's personal ThinkPad.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixos-hardware, home-manager, hyprland, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
  {
    nixosConfigurations = {
      jacob-thinkpad = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./system/filesystems.nix
          ./system/configuration.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-p14s-amd-gen2
          hyprland.nixosModules.default
          { programs.hyprland.enable = true; }
        ];
      };
    };
    homeConfigurations = {
      jacob = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./users/jacob/profile.nix
        ];
      };
    };
  };
}
