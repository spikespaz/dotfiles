{ pkgs, ... }: {
  home.packages = [ pkgs.nushell ];

  programs.vscode.extensions =
    let extensions = pkgs.callPackage ../marketplace.nix { };
    in with extensions.preferReleases;
    [
      #
      thenuprojectcontributors.vscode-nushell-lang
    ];
}
