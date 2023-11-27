args@{ self, tree, lib, inputs }:
lib.bird.mkHome args rec {
  hostPlatform.system = "x86_64-linux";
  nixpkgs = inputs.nixpkgs-unstable;
  nixpkgsArgs.config.allowUnfree = true;
  modules = with tree.users.jacob; [
    # It doesn't even work out of the box with flakes...
    # https://github.com/nix-community/home-manager/issues/2033#issuecomment-1801557851
    {
      # news.display = "silent";
      disabledModules = [ "misc/news.nix" ];
    }
    profile
    wayland.default
    hyprland.default
    wayland.suite
  ];
  # Keep this flake's overlays towards the bottom;
  # order matters. `pkgs0` may need to contain packages
  # from input flakes, otherwise this user config will fail
  # when it expects to find the twice-overridden package.
  overlays = [
    # nix user repo packages
    inputs.nur.overlay
    # packages for window manager
    inputs.hyprland-nix.overlays.default
    # nix related packages
    inputs.nix-your-shell.overlays.default
    inputs.ragenix.overlays.default
    # other packages
    inputs.slight.overlays.default
    inputs.vscode-extensions.overlays.default
    inputs.nil.overlays.default
    inputs.prism-launcher.overlays.default
    # inputs.webcord.overlays.default
    # flake lib functions that are in pkgs
    self.overlays.lib
    # flake packages
    self.overlays.default
    # updates to packages before committing upstream
    self.overlays.updates
    # override packages with an unfree license
    self.overlays.allowUnfree
    # skip the manual download for oracle's jdk
    self.overlays.oraclejdk
  ];
  extraSpecialArgs = {
    pkgs-stable = import inputs.nixpkgs-stable {
      localSystem = hostPlatform;
      inherit overlays;
      inherit (nixpkgsArgs) config;
    };
  };
}