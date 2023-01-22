{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    perlPackages.PLS
  ];

  programs.vscode.extensions = with pkgs.vscode-marketplace.vscode; [
    fractalboy.pls
  ];

  programs.vscode.userSettings = {
    "pls.cmd" = lib.getExe pkgs.perlPackages.PLS;
  };
}
