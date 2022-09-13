{
  hyprland = {
    imports = [
      ./wayland
      ./hyprland
    ];
  };

  software = {
    imports = [
      ./suite.nix
    ];
  };
}
