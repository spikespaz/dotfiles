{
  description = ''
    A Nix flake for reproducing the Linux system configurations used on
    Jacob Birkett's personal computers.
  '';

  outputs = inputs@{ self, nixpkgs, systems, ... }:
    let
      inherit (self) lib tree;
      eachSystem = lib.genAttrs (import systems);
      pkgsFor = eachSystem (system:
        import nixpkgs {
          localSystem = system;
          overlays = [ self.overlays.default ];
        });
    in {
      lib = nixpkgs.lib.extend (import ./lib);

      # The purpose of `mkFlakeTree` is to recurse the project files,
      # importing any folders with `default.nix` or files themselves.
      # This forms a structure of nested attrsets that somewhat resembles the
      # directory structure of the flake, very much like the `tree` command.
      tree = lib.birdos.mkFlakeTree ./.;

      formatter = eachSystem (system: inputs.nixfmt.packages.${system}.default);

      overlays = lib.pipe tree.overlays [
        (attrs: removeAttrs attrs [ "unfree" ])
        (lib.mapThruAttr "default")
        (attrs:
          attrs // {
            default = tree.packages.default;
            allowUnfree = pkgs: pkgs0:
              lib.birdos.mkUnfreeOverlay pkgs0 [ [ "ttf-ms-win11" ] ];
          })
      ];
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
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs.follows = "nixpkgs-unstable";

    systems.url = "github:nix-systems/default";

    nix-your-shell.url = "github:MercuryTechnologies/nix-your-shell";
    nix-your-shell.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";

    vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    # Dependencies of packages from `hyprland-nix`.
    hyprland-git.url = "github:hyprwm/hyprland";
    hyprland-xdph-git.url = "github:hyprwm/xdg-desktop-portal-hyprland";
    hyprland-protocols-git.url = "github:hyprwm/xdg-desktop-portal-hyprland";
    # I want to lock each in my own `flake.lock`,
    # and let them be used by `hyprland-nix`.
    hyprland-nix.url = "github:spikespaz/hyprland-nix";
    hyprland-nix.inputs = {
      hyprland.follows = "hyprland-git";
      hyprland-xdph.follows = "hyprland-xdph-git";
      hyprland-protocols.follows = "hyprland-protocols-git";
    };

    nil.url = "github:oxalica/nil";

    nixfmt.url = "github:serokell/nixfmt";

    # polymc.url = "github:PolyMC/PolyMC";

    prism-launcher.url = "github:PrismLauncher/PrismLauncher";
    prism-launcher.inputs.nixpkgs.follows = "nixpkgs-unstable";

    slight.url = "github:spikespaz/slight";

    # TODO patch homeage
    ragenix.url = "github:yaxitech/ragenix";

    homeage.url = "github:jordanisaacs/homeage";
  };
}
