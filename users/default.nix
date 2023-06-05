# This file defines all users' Home Manager configurations
# as seen in the flake's `homeConfigurations` output.

args@{ self, tree, lib, inputs, ... }: {
  jacob = lib.birdos.mkHome args rec {
    hostPlatform.system = "x86_64-linux";
    nixpkgs = inputs.nixpkgs-unstable;
    nixpkgsArgs.config.allowUnfree = true;
    modules = with tree.users.jacob; [
      profile
      desktops.wayland.default
      desktops.hyprland.default
      desktops.suite
    ];
    overlays = [
      # flake packages
      self.overlays.default
      # override packages with an unfree license
      self.overlays.allowUnfree
      # skip the manual download for oracle's jdk
      self.overlays.oraclejdk
      # nix user repo packages
      inputs.nur.overlay
      # packages for window manager
      inputs.hyprland.overlays.hyprland-extras
      # other packages
      inputs.slight.overlays.default
      inputs.vscode-extensions.overlays.default
      inputs.nil.overlays.default
      inputs.prism-launcher.overlays.default
      # inputs.webcord.overlays.default
      inputs.ragenix.overlays.default
    ];
    extraSpecialArgs = {
      pkgs-stable = import inputs.nixpkgs-stable {
        localSystem = hostPlatform;
        inherit overlays;
        inherit (nixpkgsArgs) config;
      };
    };
  };
}
