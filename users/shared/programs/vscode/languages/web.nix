{ lib, pkgs, ... }: {
  programs.vscode.extensions =
    let extensions = pkgs.callPackage ../marketplace.nix { };
    in with extensions.preferReleases; [
      ms-vscode.live-server
      aeschli.vscode-css-formatter
    ];

  programs.vscode.userSettings = {
    "[css]" = { "editor.defaultFormatter" = "aeschli.vscode-css-formatter"; };
  };
}
