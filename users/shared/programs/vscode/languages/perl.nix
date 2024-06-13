{ lib, pkgs, ... }: {
  programs.vscode.extensions =
    let extensions = pkgs.callPackage ../marketplace.nix { };
    in with extensions.preferReleases;
    [
      #
      fractalboy.pls
    ];

  programs.vscode.userSettings = {
    "pls.cmd" = lib.getExe pkgs.perlPackages.PLS;
  };
}
