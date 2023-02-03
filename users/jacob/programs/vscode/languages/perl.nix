{
  lib,
  pkgs,
  ...
}: {
  programs.vscode.extensions = with pkgs.vscode-marketplace; [
    fractalboy.pls
  ];

  programs.vscode.userSettings = {
    "pls.cmd" = lib.getExe pkgs.perlPackages.PLS;
  };
}
