{ pkgs, ... }: {
  programs.vscode.extensions = with pkgs.vscode-marketplace;
    with pkgs.vscode-marketplace-release;
    [ marp-team.marp-vscode ];
}
