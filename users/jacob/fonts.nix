{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Sans-serif
    lato

    # Monospace
    jetbrains-mono
    monaspace

    # Icons
    material-design-icons
    nerd-fonts.symbols-only
  ];
}
