{ lib, pkgs, ... }: {
  # home.packages = with pkgs; [
  #   perlPackages.PLS
  # ];

  programs.vscode.extensions = (
    pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "live-server";
        publisher = "ms-vscode";
        version = "0.5.2022091501";
        sha256 = "sha256-J0ckcfcCDXifp3UCBefnqT5ImTg95+1EGbWyExcIw0k=Fir";
      }
    ]
  );

  # programs.vscode.userSettings = {
  #   "pls.cmd" = lib.getExe pkgs.perlPackages.PLS;
  # };
}
