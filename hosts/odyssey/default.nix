args@{ self, tree, lib, inputs }:
lib.bird.mkHost args {
  hostPlatform = {
    system = "x86_64-linux";
  } // lib.systems.architectures.featureSupport "znver4";
  nixpkgs = inputs.nixpkgs-unstable;
  nixpkgsArgs.config.allowUnfree = true;
  modules =
    #
    with self.nixosModules;
    with tree.hosts; [
      hardware.amd-thinkpad.common
      hardware.amd-thinkpad.bootloader
      hardware.amd-thinkpad.graphics
      hardware.amd-thinkpad.airplane-mode

      # shared.amd-thinkpad.plymouth

      shared.touchpad-fix
      shared.greetd-hyprland
      # shared.gamemode
      shared.run-game
      shared.packages
      shared.nix-registry
      shared.pia-openvpn
      # shared.nixbuild
      shared.user-sessions

      ./misc.nix
      ./packages.nix
      ./filesystems.nix
      ./cpu-frequency.nix
      ./powerplan.nix
    ];
  overlays = [
    # required for rust-regressions
    inputs.rust-overlay.overlays.default
    self.overlays.rust-regressions
    # this flake's lib
    self.overlays.lib
    # flake packages
    self.overlays.default
    # override packages with an unfree license
    self.overlays.allowUnfree
    # window manager
    inputs.hyprnix.overlays.default
    # other packages
    inputs.slight.overlays.default
    inputs.ragenix.overlays.default
  ];
}
