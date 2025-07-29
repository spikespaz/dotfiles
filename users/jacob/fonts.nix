{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Monospace
    jetbrains-mono
    monaspace

    # Icons
    material-design-icons
    nerd-fonts.symbols-only
  ];
}
