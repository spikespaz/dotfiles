args@{ self, tree, lib, inputs }:
lib.bird.mkHost args {
  # hostPlatform = {
  #   system = "x86_64-linux";
  # } // lib.systems.architectures.featureSupport "znver4";
  hostPlatform.system = "x86_64-linux";
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

      shared.networking
      shared.touchpad-fix
      # shared.gamemode
      shared.run-game
      shared.packages
      shared.nix-registry
      shared.pia-openvpn
      # shared.nixbuild
      shared.user-sessions
      shared.peripherals

      ./misc.nix
      ./packages.nix
      ./filesystems.nix
      ./powerplan
    ];
  overlays = [
    # this flake's lib
    self.overlays.lib
    # updates to packages before committing upstream
    self.overlays.patches
    # flake packages
    self.overlays.default
    # override packages with an unfree license
    self.overlays.allowUnfree
    # override certain packages to be fetchable in binary caches
    self.overlays.hacks.nixpkgs-config-exceptions
    # other packages
    inputs.slight.overlays.default
    inputs.ragenix.overlays.default
  ];
}
