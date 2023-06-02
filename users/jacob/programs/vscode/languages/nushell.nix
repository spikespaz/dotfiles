{ pkgs, ... }: {
  home.packages = [ pkgs.nushell ];

  programs.vscode.extensions = with pkgs.vscode-marketplace;
    with pkgs.vscode-marketplace-release;
    [ thenuprojectcontributors.vscode-nushell-lang ];
}
