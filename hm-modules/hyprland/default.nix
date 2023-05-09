{ ... }: {
  imports = [
    ./events.nix
    ./config.nix
    ./rules.nix # windowrulev2, layerrule, workspace
    ./animations.nix
    ./keybinds.nix
  ];
}
