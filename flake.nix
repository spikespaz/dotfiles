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

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      lib = nixpkgs.lib.extend (final: prev: prev // import ./lib.nix final);
      # The purpose of `mkFlakeTree` is to recurse the project files,
      # importing any folders with `default.nix` or files themselves.
      # This forms a structure of nested attrsets that somewhat resembles the
      # directory structure of the flake, very much like the `tree` command.
      tree = lib.mkFlakeTree ./.;

      systems = tree.lib.systems;
      pkgsFor = builtins.listToAttrs (map (system: {
        name = system;
        value = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      }) systems);
      mapSystems = fn: builtins.mapAttrs fn pkgsFor;
    in {
      tree = lib.generators.toPretty { multiline = true; } tree;

      formatter =
        lib.genAttrs systems (system: inputs.nixfmt.packages.${system}.default);

      overlays = removeAttrs tree.overlays [ "unfree" ] // {
        default = _: tree.packages.default;
        allowUnfree = _: tree.overlays.unfree lib [ [ "ttf-ms-win11" ] ];
      };
      packages = lib.genAttrs systems
        (system: tree.packages.default nixpkgs.legacyPackages.${system});

      nixosModules = lib.mapThruAttr "default" tree.modules;
      homeManagerModules = lib.mapThruAttr "default" tree.hm-modules;

      nixosConfigurations =
        tree.hosts.default { inherit self lib tree inputs nixpkgs; };

      homeConfigurations =
        tree.users.default { inherit self lib tree inputs nixpkgs; };
    };
}
