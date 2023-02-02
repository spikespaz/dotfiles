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

    webcord.url = "github:fufexan/webcord-flake";
    webcord.inputs.nixpkgs.follows = "nixpkgs";

    spicetify.url = "github:the-argus/spicetify-nix";
    spicetify.inputs.nixpkgs.follows = "nixpkgs";

    # polymc.url = "github:PolyMC/PolyMC";
    # polymc.inputs.nixpkgs.follows = "nixpkgs";

    prismlauncher.url = "github:PrismLauncher/PrismLauncher";
    prismlauncher.inputs.nixpkgs.follows = "nixpkgs";

    homeage.url = "github:jordanisaacs/homeage";
    homeage.inputs.nixpkgs.follows = "nixpkgs";

    slight.url = "github:spikespaz/slight";
    slight.inputs.nixpkgs.follows = "nixpkgs";

    # TODO patch homeage
    # ragenix.url = "github:yaxitech/ragenix";
    # ragenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    nur,
    vscode-extensions,
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

    inputPackageOverlays = flib.mkPackagesOverlay system (
      removeAttrs inputs [
        "nixpkgs"
        "nur"
        "vscode-extensions"
      ]
    );
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        inputPackageOverlays
        nur.overlay
        (_: _: {vscode-marketplace = vscode-extensions.extensions.${system};})
        self.overlays.${system}.default
        self.overlays.${system}.fixes
        self.overlays.${system}.allowUnfree
      ];
    };
    pkgs-stable = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    nixosModules = flib.joinNixosModules inputs;
    homeModules = flib.joinHomeModules inputs;

    genSystems = lib.genAttrs ["x86_64-linux"];

    # TODO cannot handle scoped packages
    mkUnfreeOverlay = pkgs: names:
      lib.pipe names [
        (map (name: {
          inherit name;
          value = pkgs.${name};
        }))
        builtins.listToAttrs
        (builtins.mapAttrs (_: package:
          package.overrideAttrs (
            old:
              lib.recursiveUpdate old {
                meta.license = (
                  if builtins.isList old.meta.license
                  then map (_: {free = true;}) old.meta.license
                  else {free = true;}
                );
              }
          )))
      ];
  in {
    # packages = dotpkgs.packages;
    overlays = genSystems (_: {
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
      fixes = import ./overlays lib;
      allowUnfree = _: prev:
        mkUnfreeOverlay prev [
          "ttf-ms-win11"
        ];
    });

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
          clight
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
