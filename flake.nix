{
  description = ''
    A Nix flake for reproducing the Linux system configurations used on
    Jacob Birkett's personal computers.
  '';

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs.follows = "nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";

    vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    hyprland.url = "github:hyprwm/hyprland";
    # this prevents cache hits
    # hyprland.inputs.nixpkgs.follows = "nixpkgs";

    nil.url = "github:oxalica/nil";
    nil.inputs.nixpkgs.follows = "nixpkgs";

    # alejandra.url = "github:kamadorueda/alejandra";
    # alejandra.inputs.nixpkgs.follows = "nixpkgs";

    nixfmt.url = "github:serokell/nixfmt";

    # use the package from nixpkgs, probably better-kept
    # but this flake provides the module (which I contribute to)
    webcord.url = "github:fufexan/webcord-flake";
    webcord.inputs.nixpkgs.follows = "nixpkgs";

    spicetify.url = "github:the-argus/spicetify-nix";
    spicetify.inputs.nixpkgs.follows = "nixpkgs";

    # polymc.url = "github:PolyMC/PolyMC";
    # polymc.inputs.nixpkgs.follows = "nixpkgs";

    prism-launcher.url = "github:PrismLauncher/PrismLauncher";
    prism-launcher.inputs.nixpkgs.follows = "nixpkgs";

    homeage.url = "github:jordanisaacs/homeage";
    homeage.inputs.nixpkgs.follows = "nixpkgs";

    slight.url = "github:spikespaz/slight";
    slight.inputs.nixpkgs.follows = "nixpkgs";

    # TODO patch homeage
    ragenix.url = "github:yaxitech/ragenix";
    ragenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-stable, home-manager, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib.extend (final: prev: prev // import ./lib.nix final);
      # The purpose of `mkFlakeTree` is to recurse the project files,
      # importing any folders with `default.nix` or files themselves.
      # This forms a structure of nested attrsets that somewhat resembles the
      # directory structure of the flake, very much like the `tree` command.
      tree = lib.mkFlakeTree ./.;

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          self.overlays.default
          self.overlays.oraclejdk
          self.overlays.handbrake
          self.overlays.nushell
          self.overlays.allowUnfree
          inputs.nur.overlay
          inputs.hyprland.overlays.default
          inputs.slight.overlays.default
          inputs.vscode-extensions.overlays.default
          # inputs.alejandra.overlays.default
          inputs.nil.overlays.default
          inputs.prism-launcher.overlays.default
          # inputs.webcord.overlays.default
          inputs.ragenix.overlays.default
        ];
      };

      pkgs-stable = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      formatter.${system} = inputs.nixfmt.packages.${system}.default;

      overlays = tree.overlays // {
        default = _: tree.packages;
        allowUnfree = _: prev: lib.mkUnfreeOverlay prev [ "ttf-ms-win11" ];
      };
      packages = lib.genAttrs [ "x86_64-linux" ]
        (system: tree.packages nixpkgs.legacyPackages.${system});

      nixosModules = tree.modules;
      homeManagerModules = tree.hm-modules;

      nixosConfigurations = {
        jacob-thinkpad = lib.nixosSystem {
          system = "x86_64-linux";
          inherit pkgs;

          specialArgs = {
            inherit self lib tree inputs nixpkgs nixpkgs-stable pkgs-stable;
            enableUnstableZfs = false;
          };

          modules = with tree.systems.jacob-thinkpad; [
            bootloader
            filesystems
            plymouth
            configuration
            powerplan
            touchpad
            greeter
            # gamemode
            gaming
            pia-openvpn
          ];
        };
      };

      homeConfigurations = {
        jacob = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            lib = lib.extend (final: _: {
              hm = import "${home-manager}/modules/lib" { lib = final; };
            });
            inherit self tree inputs nixpkgs nixpkgs-stable pkgs-stable;
          };

          modules = with tree.users.jacob; [
            profile
            desktops.wayland
            desktops.hyprland
            desktops.suite
          ];
        };
      };
    };
}
