# This file defines all NixOS host configurations
# as seen in the flake's `nixosConfigurations` output.

args@{ self, tree, lib, inputs, ... }: {
  intrepid = lib.bird.mkHost args {
    hostPlatform.system = "x86_64-linux";
    nixpkgs = inputs.nixpkgs-unstable;
    nixpkgsArgs.config.allowUnfree = true;
    # the bootloader module takes this as a param
    # determines if should use untested kernel with zfs
    specialArgs.enableUnstableZfs = false;
    modules = with tree.hosts.intrepid; [
      bootloader
      filesystems
      # plymouth
      configuration
      packages
      nixbuild
      registry
      powerplan
      touchpad
      greeter
      # gamemode
      gaming
      pia-openvpn
      user-desktop
    ];
    overlays = [
      # flake packages
      self.overlays.default
      # override packages with an unfree license
      self.overlays.allowUnfree
      # window manager
      inputs.hyprland-nix.overlays.default
      # other packages
      inputs.slight.overlays.default
      inputs.ragenix.overlays.default
    ];
  };
}
