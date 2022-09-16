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

    inherit (nixpkgs) lib;
    flib = import ./lib.nix lib;

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      config.allowBroken = true;
      overlays = [
        self.overlays.${system}.allPackages
        self.overlays.${system}.allowUnfree
      ];
    };

    # manually import the packages subflake to avoid locking issues
    # this flake must have the same inputs that dotpkgs expects
    dotpkgs = (import ./dotpkgs/flake.nix).outputs inputs;
  in {
    # merge the packages flake into this one
    inherit (dotpkgs) packages overlays nixosModules homeManagerModules;

    nixosConfigurations = {
      jacob-thinkpad = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          { nixpkgs.pkgs = pkgs; }
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

        extraSpecialArgs = {
          nil = flib.flatFlake inputs.nil system;
          webcord = flib.flatFlake inputs.webcord system;

          hmModules = flib.joinHmModules {
            dotpkgs = self;
            hyprland = inputs.hyprland;
          };
        };
      };
    };
  };
}
