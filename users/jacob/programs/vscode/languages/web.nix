{
  lib,
  pkgs,
  ...
}: {
  # home.packages = with pkgs; [
  #   perlPackages.PLS
  # ];

  programs.vscode.extensions = (
    pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "live-server";
        publisher = "ms-vscode";
        version = "0.5.2022101301";
        sha256 = "sha256-FQ1UKHO6zr7H+1OjfzZblgLcCQf9436S87A2/73iF7k=";
      }
    ]
  );

  # programs.vscode.userSettings = {
  #   "pls.cmd" = lib.getExe pkgs.perlPackages.PLS;
  # };
}
