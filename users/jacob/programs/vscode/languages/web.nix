{ lib, pkgs, ... }: {
  programs.vscode.extensions = with pkgs.vscode-marketplace; [
    ms-vscode.live-server
    aeschli.vscode-css-formatter
  ];

  programs.vscode.userSettings = {
    "[css]" = { "editor.defaultFormatter" = "aeschli.vscode-css-formatter"; };
  };
}
