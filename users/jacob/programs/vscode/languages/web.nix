profileName:
{ pkgs, ... }: {
  programs.vscode.profiles.${profileName} = {
    extensions = let extensions = pkgs.callPackage ../marketplace.nix { };
    in with extensions.preferReleases; [
      ms-vscode.live-server
      aeschli.vscode-css-formatter
    ];

    userSettings = {
      "[css]" = { "editor.defaultFormatter" = "aeschli.vscode-css-formatter"; };
    };
  };
}
