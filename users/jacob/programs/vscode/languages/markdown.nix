profileName:
{ lib, pkgs, ... }: {
  programs.vscode.profiles.${profileName} = {
    extensions = let extensions = pkgs.callPackage ../marketplace.nix { };
    in with extensions.preferReleases; [ # #
      yzhang.markdown-all-in-one

      bierner.markdown-emoji
      bierner.emojisense
      bierner.markdown-footnotes
      bierner.markdown-mermaid
    ];

    userSettings = {
      # enable error reporting, missing or unused links for example
      "markdown.validate.enabled" = true;
    };
  };
}
