{ lib, pkgs, ... }: {
  programs.vscode.extensions = with pkgs.vscode-marketplace;
    with pkgs.vscode-marketplace-release; [
      eww-yuck.yuck
      kress95.vscode-parinfer-kress95
    ];

  # programs.vscode.userSettings = {
  #   "[css]" = {
  #     "editor.defaultFormatter" = "aeschli.vscode-css-formatter";
  #   };
  # };
}
