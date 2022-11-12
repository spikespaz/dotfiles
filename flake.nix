{
  description = ''
    A Nix flake for reproducing the Linux system configurations used on
    Jacob Birkett's personal computers.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";

    hyprland.url = "github:hyprwm/hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";

    nil.url = "github:oxalica/nil";
    nil.inputs.nixpkgs.follows = "nixpkgs";

    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
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
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    nur,
    ...
  }: let
    system = "x86_64-linux";

    inherit (nixpkgs) lib;
    flib = import ./lib.nix {inherit lib pkgs;};

    # get directory structure as nested attrsets of modules
    flake = flib.evalIndices {
      expr = ./.;
      isRoot = true;
      pass = {inherit lib pkgs;};
    };

    inputPackageOverlays = flib.mkPackagesOverlay system (
      removeAttrs inputs [
        "nixpkgs"
        "nur"
      ]
    );
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        inputPackageOverlays
        nur.overlay
        self.overlays.${system}.allowUnfree
        self.overlays.${system}.nixpkgsFixes
      ];
    };
    # manually import the packages subflake to avoid locking issues
    # this flake must have the same inputs that dotpkgs expects
    dotpkgs = (import ./dotpkgs/flake.nix).outputs inputs;

    nixosModules = flib.joinNixosModules inputs;
    homeModules = flib.joinHomeModules inputs;
  in {
    # merge the packages flake into this one
    inherit (dotpkgs) packages overlays nixosModules homeManagerModules;

    nixosConfigurations = {
      jacob-thinkpad = lib.nixosSystem {
        system = "x86_64-linux";
        inherit pkgs;

        specialArgs = {
          inherit self flake;
          modules = nixosModules;
          enableUnstableZfs = false;
        };

        modules = lib.trace flake.wayland (with flake.systems.jacob-thinkpad; [
          bootloader
          filesystems
          plymouth
          configuration
          powersave
          undervolt
          touchpad
          greeter
          gamemode
          flake.wayland.scripts.disable_kb
        ]);
      };
    };

    homeConfigurations = {
      jacob = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit self flake nixpkgs;
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
