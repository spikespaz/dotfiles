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

    pkgs = nixpkgs.legacyPackages.${system};
    # manually import the packages subflake to avoid locking issues
    # this flake must have the same inputs that dotpkgs expects
  in {
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

        specialArgs = {
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
          dotpkgs = self;
          hyprland = inputs.hyprland;
          nil = inputs.nil;
          webcord = inputs.webcord;
        };
      };
    };

    packages.${system} = let
      inherit (pkgs) lib;

      pkgs = nixpkgs.legacyPackages.${system};
      this = self.packages.${system};
      maintainers = import ./maintainers.nix;
      callWith = { inherit maintainers; };
    in {
      ttf-ms-win11 = lib.callPackageWith
        (pkgs // this) ./dotpkgs/ttf-ms-win11/package.nix callWith;
      lapce = lib.callPackageWith
        (pkgs // this) ./dotpkgs/lapce/package.nix callWith;
      fastfetch = lib.callPackageWith
        (pkgs // this) ./dotpkgs/fastfetch/package.nix callWith;
      idlehack = lib.callPackageWith
        (pkgs // this) ./dotpkgs/idlehack/package.nix callWith;
      prtsc = lib.callPackageWith
        (pkgs // this) ./dotpkgs/prtsc/package.nix callWith;
    };

    nixosModules = {
      auto-cpufreq = import ./dotpkgs/auto-cpufreq/module.nix inputs;
    };

    homeManagerModules = {
      kvantum = import ./dotpkgs/kvantum/hm-module.nix inputs;
      uniform-theme = import ./dotpkgs/uniform-theme/hm-module.nix inputs;
      idlehack = import ./dotpkgs/idlehack/hm-module.nix inputs;
      randbg = import ./dotpkgs/randbg/hm-module.nix inputs;
      zsh-uncruft = import ./dotpkgs/zsh-uncruft/hm-module.nix inputs;
    };
  };
}
