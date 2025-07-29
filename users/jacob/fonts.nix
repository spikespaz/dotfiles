{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Superfamilies
    ibm-plex

    # Sans-serif
    carlito
    lato

    # Monospace
    jetbrains-mono
    monaspace

    # Icons
    material-design-icons
    nerd-fonts.symbols-only
  ];
}
