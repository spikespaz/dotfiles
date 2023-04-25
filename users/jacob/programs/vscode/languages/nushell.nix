{ pkgs, ... }: {
  home.packages = [ pkgs.nushell ];

  programs.vscode.extensions = with pkgs.vscode-marketplace;
    [ thenuprojectcontributors.vscode-nushell-lang ];
}
