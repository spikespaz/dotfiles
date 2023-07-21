{ ... }: {
  disabledModules = [
    # module in Home Manager conflicts with this one
    "services/window-managers/hyprland.nix"
  ];

  imports = [
    ./events.nix
    ./config.nix
    ./rules.nix # windowrulev2, layerrule, workspace
    ./animations.nix
    ./keybinds.nix
  ];
}
