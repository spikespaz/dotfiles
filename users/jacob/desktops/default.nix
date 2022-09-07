{
  hyprland = {
    imports = [
      ./theming.nix
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
