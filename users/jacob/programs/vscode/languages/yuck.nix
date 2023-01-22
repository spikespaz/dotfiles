{
  lib,
  pkgs,
  ...
}: {
  programs.vscode.extensions = with pkgs.vscode-marketplace.vscode; [
    eww-yuck.yuck
    kress95.vscode-parinfer-kress95
  ];

  # programs.vscode.userSettings = {
  #   "[css]" = {
  #     "editor.defaultFormatter" = "aeschli.vscode-css-formatter";
  #   };
  # };
}
