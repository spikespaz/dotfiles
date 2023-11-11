{
  description = ''
    A Nix flake for reproducing the Linux system configurations used on
    Jacob Birkett's personal computers.
  '';

  outputs = inputs@{ self, nixpkgs, systems, ... }:
    let
      inherit (self) lib tree;
      eachSystem = lib.genAttrs (import systems);
    in {
      lib = builtins.foldl' (lib: overlay: lib.extend overlay) nixpkgs.lib [
        (inputs.bird-nix-lib.lib.overlay)
        (import ./lib)
      ];

      # $ nix eval 'path:.#tests'
      tests = import ./tests { inherit lib; };

      tree = lib.bird.importDirRecursive ./. "flake.nix";

      formatter = eachSystem (system: inputs.nixfmt.packages.${system}.default);

      /*
        $ nix eval 'path:.#overlays' | sed 's/<|>/"/g' | nixfmt
        ---
        There is an overlay for each package:

          - fork-awesome
          - idlehack
          - ja-netfilter
          - nerdfonts-symbols
          - proton-ge-custom
          - prtsc
          - ttf-ms-win11
          - zsh-plugins

        Then there are collections/utilities also available as overlays:

          - lib = extra functions merged into `pkgs`
          - allowUnfree - override `meta.license` of certain packages
          - oraclejdk - overrides `oraclejdk` to not `requireFile`
          - default - all packages from this flake
          - updates - some small updates/fixes for certain packages
      */
      overlays = let packageOverlays = import ./packages/overlays.nix lib;
      in import ./overlays lib packageOverlays;

      /*
        $ nix eval 'path:.#packages.x86_64-linux' --apply 'builtins.attrNames' | nixfmt
        [
          "fork-awesome"
          "idlehack"
          "ja-netfilter"
          "nerdfonts-symbols"
          "proton-ge-custom"
          "prtsc"
          "ttf-ms-win11"
          "zsh-auto-notify"
          "zsh-autocomplete"
          "zsh-autopair"
          "zsh-autosuggestions"
          "zsh-edit"
          "zsh-fast-syntax-highlighting"
          "zsh-window-title"
        ]
      */
      packages =
        eachSystem (system: import ./packages { inherit lib system nixpkgs; });

      # since `tree` closely represents the file tree of the flake,
      # there are `default` attrs in some of the "folders".
      # `mapThruAttr` will take an attrs of attrs and transparently get the
      # `default` attributes for the second-level sets that have them.
      nixosModules = lib.importDir' ./modules null;
      homeManagerModules = lib.importDir ./hm-modules null;

      # for more information about the host configurations,
      # see ./hosts/default.nix
      nixosConfigurations =
        import ./hosts { inherit self lib tree inputs nixpkgs; };

      # for more information aboyt user configurations,
      # see ./users/default.nix
      homeConfigurations =
        import ./users { inherit self lib tree inputs nixpkgs; };
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
    bird-nix-lib.url = "github:spikespaz/bird-nix-lib";

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
