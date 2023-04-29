{
  description = ''
    A Nix flake for reproducing the Linux system configurations used on
    Jacob Birkett's personal computers.
  '';

  outputs = inputs@{ self, nixpkgs, ... }:
    let inherit (self) lib tree systems;
    in {
      # any of aarch64, arm, x86_64, linux and darwin.
      # other platforms may be negotiable.
      systems = with lib.systems.doubles;
        lib.birdos.mkFlakeSystems [
          [ x86_64 linux ]
          [ arm linux ]
          [ aarch64 linux ]
          [ arm darwin ]
          [ aarch64 darwin ]
        ];

      lib = nixpkgs.lib.extend (import ./lib);

      # The purpose of `mkFlakeTree` is to recurse the project files,
      # importing any folders with `default.nix` or files themselves.
      # This forms a structure of nested attrsets that somewhat resembles the
      # directory structure of the flake, very much like the `tree` command.
      tree = lib.birdos.mkFlakeTree ./.;

      formatter =
        lib.genAttrs systems (system: inputs.nixfmt.packages.${system}.default);

      overlays = removeAttrs tree.overlays [ "unfree" ] // {
        default = _: tree.packages.default;
        allowUnfree = _: tree.overlays.unfree lib [ [ "ttf-ms-win11" ] ];
      };
      packages = lib.genAttrs systems
        (system: tree.packages.default nixpkgs.legacyPackages.${system});

      # since `tree` closely represents the file tree of the flake,
      # there are `default` attrs in some of the "folders".
      # `mapThruAttr` will take an attrs of attrs and transparently get the
      # `default` attributes for the second-level sets that have them.
      nixosModules = lib.mapThruAttr "default" tree.modules;
      homeManagerModules = lib.mapThruAttr "default" tree.hm-modules;

      # for more information about the host configurations,
      # see ./hosts/default.nix
      nixosConfigurations =
        tree.hosts.default { inherit self lib tree inputs nixpkgs; };

      # for more information aboyt user configurations,
      # see ./users/default.nix
      homeConfigurations =
        tree.users.default { inherit self lib tree inputs nixpkgs; };
    };

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
}
