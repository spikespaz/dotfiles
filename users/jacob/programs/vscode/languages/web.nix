{ lib, pkgs, ... }: {
  programs.vscode.extensions =
    #
    with pkgs.vscode-marketplace;
    with pkgs.vscode-marketplace-release; [
      ms-vscode.live-server
      aeschli.vscode-css-formatter
    ];

  programs.vscode.userSettings = {
    "[css]" = { "editor.defaultFormatter" = "aeschli.vscode-css-formatter"; };
  };
}
