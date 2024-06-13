{ pkgs, ... }: {
  programs.vscode.extensions =
    let extensions = pkgs.callPackage ../marketplace.nix { };
    in with extensions.preferReleases;
    [
      #
      marp-team.marp-vscode
    ];
}
