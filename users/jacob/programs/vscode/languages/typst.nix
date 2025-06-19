profileName:
{ lib, pkgs, ... }: {
  programs.vscode.profiles.${profileName} = {
    extensions = let extensions = pkgs.callPackage ../marketplace.nix { };
    in with extensions.preferReleases;
    [ # #
      myriad-dreamin.tinymist
    ];

    userSettings = { };
  };
}
