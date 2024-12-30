args@{ self, tree, lib, nixpkgs, inputs }:
let
  inherit (inputs) home-manager;

  overlays = [
    # make the `home-manager` command follow flake input's version
    (import "${home-manager}/overlay.nix")
    self.overlays.lib
  ];
  pkgs = import nixpkgs {
    localSystem.system = "aarch64-darwin";
    inherit overlays;
    config.allowUnfree = true;
  };
  lib = args.lib.extend
    (lib: _: { hm = import "${home-manager}/modules/lib" { inherit lib; }; });

  disableHomeManagerNews = {
    config = {
      news.display = "silent";
      news.json = lib.mkForce { };
      news.entries = lib.mkForce [ ];
    };
  };

  modules = [ disableHomeManagerNews ./profile.nix ];
in home-manager.lib.homeManagerConfiguration {
  inherit pkgs modules;
  extraSpecialArgs = { inherit nixpkgs lib; };
}
