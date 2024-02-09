args@{ self, tree, lib, inputs }:
lib.bird.mkHost args {
  hostPlatform.system = "x86_64-linux";
  nixpkgs = inputs.nixpkgs-unstable;
  nixpkgsArgs.config.allowUnfree = true;
  # the bootloader module takes this as a param
  # determines if should use untested kernel with zfs
  specialArgs.enableUnstableZfs = false;
  modules = with tree.hosts; [
    shared.amd-thinkpad.hardware
    shared.amd-thinkpad.bootloader
    # shared.amd-thinkpad.plymouth
    shared.amd-thinkpad.user-desktop

    shared.touchpad-fix
    shared.greetd-hyprland
    # shared.gamemode
    shared.run-game
    shared.packages
    shared.nix-registry
    shared.pia-openvpn
    # shared.nixbuild

    ./misc.nix
    ./packages.nix
    ./filesystems.nix
    ./cpu-frequency.nix
    ./powerplan.nix
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
}
