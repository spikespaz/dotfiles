profileName:
{ lib, pkgs, ... }: {
  home.packages = with pkgs; [ noto-fonts ];

  programs.vscode.profiles.${profileName} = {
    extensions = let extensions = pkgs.callPackage ../marketplace.nix { };
    in with extensions.preferReleases; [ # #
      yzhang.markdown-all-in-one
      davidanson.vscode-markdownlint

      bierner.markdown-emoji
      bierner.emojisense
      bierner.markdown-footnotes
      bierner.markdown-mermaid
      bpruitt-goddard.mermaid-markdown-syntax-highlighting
    ];

    userSettings = {
      # enable error reporting, missing or unused links for example
      "markdown.validate.enabled" = true;

      # ask if links should be updated when a markdown file is moved in the workspace
      "markdown.updateLinksOnFileMove.enabled" = "prompt";

      # enable completion, for example lists and block quotes
      "markdown.extension.completion.enabled" = true;

      # language-neutral beautification (such as asymmetric quotations)
      "markdown.preview.typographer" = true;

      # configure font and size
      "markdown.preview.fontFamily" =
        lib.concatMapStringsSep ", " (s: "'${s}'") [
          "Noto Sans"
          "Noto Color Emoji"
          "system-ui"
        ];
      "markdown.preview.fontSize" = 16;

      "markdownlint.config" = {
        # allow multiple top-level headings
        "MD025" = false;
        # allow blank lines inside block-quotes (to allow adjacency)
        "MD028" = false;
      };

      # format with `vscode-markdownlint` instead of `markdown-all-in-one`
      "[markdown]" = {
        "editor.defaultFormatter" = "DavidAnson.vscode-markdownlint";
      };
    };
  };
}
