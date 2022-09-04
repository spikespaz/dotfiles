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
    dots = import ./lib.nix;
  in {
    # nixosConfigurations = {
    #   jacob-thinkpad = nixpkgs.lib.nixosSystem {
    #     inherit system;

    #     modules = [
    #       nixos-hardware.nixosModules.lenovo-thinkpad-p14s-amd-gen2
    #       ./system/filesystems.nix
    #       ./system/configuration.nix
    #       ./system/powersave.nix
    #     ];
    #   };
    # };
    # homeConfigurations = {
    #   jacob = home-manager.lib.homeManagerConfiguration {
    #     inherit pkgs;

    #     modules = [
    #       hyprland.homeManagerModules.default
    #       ./users/jacob/profile.nix
	  #       ./users/jacob/desktop
    #     ];

    #     extraSpecialArgs = {
    #       inherit inputs;
    #     };
    #   };
    # };
    inherit dots.mkConfigs {
      jacob-thinkpad = {
        inherit system;

        modules = [
          nixos-hardware.nixosModules.lenovo-thinkpad-p14s-amd-gen2
          ./hosts/common/zfs-filesystems.nix
          ./hosts/common/laptop/powersave.nix
          ./hosts/thinkpad-p14s-gen1/powersave.nix
          ./hosts/thinkpad-p14s-gen1/configuration.nix
          { environment.systemPackages = import ./hosts/common/core-packages.nix pkgs; }
        ];

        users = {
          jacob = let
            cfgs = import ./users/jacob/config-groups.nix;
          in {
            description = "Jacob Birkett";
            initialPassword = "password1234";

            inherit pkgs;
            inherit inputs;

            modules = [
              hyprland.homeManagerModules.default
              ./users/jacob
              
              ./users/jacob/desktop/wl-hyprland
              ./users/jacob/desktop/wl-common
              ./users/jacob/desktop/wl-powersave

              ./users/jacob/environ/wl-flatpak
              ./users/jacob/environ/wl-appimage

              cfgs.apps.browsers.edge
              cfgs.apps.browsers.firefox
              cfgs.apps.browsers.chromium

              cfgs.apps.office
              cfgs.apps.recording
              cfgs.apps.communication

              cfgs.cli.shells.zsh
              cfgs.cli.shells.bash
              cfgs.cli.terms.alacritty

              cfgs.devel.base
              
              cfgs.devel.editors.vscode.bash
              cfgs.devel.editors.vscode.nix
              cfgs.devel.editors.vscode.rust
              cfgs.devel.editors.vscode.perl
              cfgs.devel.editors.vscode.java
              cfgs.devel.editors.vscode.python

              cfgs.devel.editors.clion
              cfgs.devel.editors.intellij
              cfgs.devel.editors.pycharm

              cfgs.devel.langs.nix
              cfgs.devel.langs.rust
              cfgs.devel.langs.perl
              cfgs.devel.langs.java
              cfgs.devel.langs.python
            ];
          }
        };
      };
    };
  };
}
