profileName:
{ lib, pkgs, ... }: {
  programs.vscode.profiles.${profileName} = {
    extensions = let extensions = pkgs.callPackage ../marketplace.nix { };
    in with extensions.preferReleases; [
      myriad-dreamin.tinymist
      mathematic.vscode-pdf
    ];

    userSettings = {
      "tinymist.formatterMode" = "typstyle";
    };
  };
}
