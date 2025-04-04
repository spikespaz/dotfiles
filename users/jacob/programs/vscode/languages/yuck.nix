profileName:
{ pkgs, ... }: {
  programs.vscode.profiles.${profileName} = {
    extensions = let extensions = pkgs.callPackage ../marketplace.nix { };
    in with extensions.preferReleases; [
      eww-yuck.yuck
      kress95.vscode-parinfer-kress95
    ];

    # programs.vscode.userSettings = {
    #   "[css]" = {
    #     "editor.defaultFormatter" = "aeschli.vscode-css-formatter";
    #   };
    # };
  };
}
