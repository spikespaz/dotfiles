{
  description = ''
    A Nix flake for reproducing the Linux system configurations used on
    Jacob Birkett's personal computers.
  '';

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      inherit (self) lib tree systems;
      pkgsFor = lib.genAttrs systems
        (system: import nixpkgs { overlays = [ self.overlays.default ]; });
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
        default = tree.packages.default;
        allowUnfree = _: prev:
          lib.birdos.mkUnfreeOverlay prev [ [ "ttf-ms-win11" ] ];
      };
      packages =
        builtins.mapAttrs (_: pkgs: tree.packages.default pkgs pkgs) pkgsFor;

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

  # Do not use `<input>.inputs.*.follows` unless there is a good reason.
  # Changing which inputs follow others also determines the derivations
  # to use as package dependencies, and will cause derivations (with new hashes)
  # to miss the binary caches.
  #
  # If it is truly desired to use input's packages built with different
  # packages from what is specified in the input's `flake.lock` file,
  # you should probably be using overlays and accessing packages from
  # `pkgs` passed to your module's arguments.
  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs.follows = "nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";

    vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    hyprland.url = "github:hyprwm/hyprland";

    # The Hyprland input and its dependencies are overridden until
    # <https://github.com/hyprwm/Hyprland/pull/2210>
    # is merged, this uses my `fix-overlay` branch
    # so that Wayland doesn't conflict with `nixpkgs-unstable`.
    # hyprland-protocols.url = "github:spikespaz/hyprland-protocols/fix-overlays";
    # xdph.url = "github:spikespaz/xdg-desktop-portal-hyprland/fix-overlays";
    # hyprland.url = "github:spikespaz/hyprland-window-manager/fix-overlays";
    # hyprland.inputs.hyprland-protocols.follows = "hyprland-protocols";
    # hyprland.inputs.xdph.follows = "xdph";

    nil.url = "github:oxalica/nil";

    nixfmt.url = "github:serokell/nixfmt";

    # use the package from nixpkgs, probably better-kept
    # but this flake provides the module (which I contribute to)
    webcord.url = "github:fufexan/webcord-flake";

    spicetify.url = "github:the-argus/spicetify-nix";

    # polymc.url = "github:PolyMC/PolyMC";

    prism-launcher.url = "github:PrismLauncher/PrismLauncher";

    slight.url = "github:spikespaz/slight";

    # TODO patch homeage
    ragenix.url = "github:yaxitech/ragenix";

    homeage.url = "github:jordanisaacs/homeage";
  };
}
