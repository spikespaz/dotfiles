args@{ self, tree, lib, inputs, ... }: {
  jacob = lib.birdos.mkHome args {
    system = "x86_64-linux";
    nixpkgs = inputs.nixpkgs-unstable;
    nixpkgsArgs.config.allowUnfree = true;
    modules = with tree.users.jacob; [
      profile
      desktops.wayland.default
      desktops.hyprland.default
      desktops.suite
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
