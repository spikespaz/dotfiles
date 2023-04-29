# this is specialArgs defaults
args@{ self, tree, lib, inputs, ... }: {
  jacob-thinkpad = lib.mkHost args {
    system = "x86_64-linux";
    nixpkgs = inputs.nixpkgs-unstable;
    nixpkgsArgs.config.allowUnfree = true;
    specialArgs.enableUnstableZfs = false;
    modules = with tree.hosts.jacob-thinkpad; [
      bootloader
      filesystems
      plymouth
      configuration
      powerplan
      touchpad
      greeter
      # gamemode
      gaming
      pia-openvpn
    ];
    overlays = [
      self.overlays.default
      self.overlays.oraclejdk
      self.overlays.handbrake
      self.overlays.nushell
      self.overlays.allowUnfree
      inputs.nur.overlay
      inputs.hyprland.overlays.default
      inputs.slight.overlays.default
      inputs.vscode-extensions.overlays.default
      # inputs.alejandra.overlays.default
      inputs.nil.overlays.default
      inputs.prism-launcher.overlays.default
      # inputs.webcord.overlays.default
      inputs.ragenix.overlays.default
    ];
  };
}
