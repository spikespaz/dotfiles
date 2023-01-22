{
  lib,
  pkgs,
  ...
}: {
  programs.vscode.extensions = with pkgs.vscode-marketplace.vscode; [
    fractalboy.pls
  ];

  programs.vscode.userSettings = {
    "pls.cmd" = lib.getExe pkgs.perlPackages.PLS;
  };
}
