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

    alejandra.url = "github:kamadorueda/alejandra";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";

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

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    ...
  }: let
    system = "x86_64-linux";

    inherit (nixpkgs) lib;
    flib = import ./lib.nix {inherit lib pkgs;};

    # get directory structure as nested attrsets of modules
    flake = flib.evalIndices {
      expr = ./.;
      isRoot = true;
      pass = {inherit lib pkgs flake flib;};
    };

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        self.overlays.default
        self.overlays.oraclejdk
        self.overlays.handbrake
        self.overlays.allowUnfree
        inputs.nur.overlay
        inputs.hyprland.overlays.default
        inputs.slight.overlays.default
        inputs.vscode-extensions.overlays.default
        inputs.alejandra.overlays.default
        inputs.nil.overlays.default
        inputs.prism-launcher.overlay
        # inputs.webcord.overlays.default
        inputs.ragenix.overlays.default
      ];
    };
    pkgs-stable = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    nixosModules = flib.joinNixosModules inputs;
    homeModules = flib.joinHomeModules inputs;
  in {
    overlays =
      flake.overlays
      // {
        default = _: prev:
          builtins.mapAttrs (_: p:
            prev.callPackage p (let
              pass = {
                maintainers = import ./maintainers.nix;
              };
              fArgs = builtins.functionArgs p;
            in
              lib.filterAttrs (n: _: fArgs ? ${n}) pass))
          flake.packages;
        allowUnfree = _: prev:
          flib.mkUnfreeOverlay prev [
            "ttf-ms-win11"
          ];
      };
    packages = lib.genAttrs ["x86_64-linux"] (
      system:
        self.overlays.default null nixpkgs.legacyPackages.${system}
    );

    nixosModules = flake.modules;
    homeManagerModules = flake.hm-modules;

    nixosConfigurations = {
      jacob-thinkpad = lib.nixosSystem {
        system = "x86_64-linux";
        inherit pkgs;

        specialArgs = {
          inherit self flake;
          modules = nixosModules;
          enableUnstableZfs = false;
        };

        modules = with flake.systems.jacob-thinkpad; [
          bootloader
          filesystems
          plymouth
          configuration
          powersave
          undervolt
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
          inherit
            self
            flake
            nixpkgs
            nixpkgs-stable
            pkgs-stable
            ;
          hmModules = homeModules;
          ulib = flake.users.lib;
        };

        modules = with flake.users.jacob; [
          profile
          mimeapps
          desktops.wayland
          desktops.hyprland
          desktops.suite
          desktops.mimeapps
        ];
      };
    };
  };
}
