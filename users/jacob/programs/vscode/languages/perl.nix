profileName:
{ lib, pkgs, ... }: {
  programs.vscode.profiles.${profileName} = {
    extensions = let extensions = pkgs.callPackage ../marketplace.nix { };
    in with extensions.preferReleases;
    [
      #
      fractalboy.pls
    ];

    userSettings = { "pls.cmd" = lib.getExe pkgs.perlPackages.PLS; };
  };
}
