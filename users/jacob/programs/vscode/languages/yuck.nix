{
  lib,
  pkgs,
  ...
}: {
  programs.vscode.extensions =
    (
      pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "eww-yuck";
          publisher = "yuck";
          version = "v0.0.3";
          sha256 = "";
        }
      ]
    )
    ++ (
      map pkgs.vscode-utils.buildVscodeExtension [
        rec {
          name = "vscode-parnifer";
          src = pkgs.fetchFromGitHub {
            owner = "oakmac";
            repo = name;
            rev = "v0.6.1";
            sha256 = "";
          };
          vscodeExtPublisher = "oakmac";
          vscodeExtName = name;
          vscodeExtUniqueId = "unknown";
        }
      ]
    );

  # programs.vscode.userSettings = {
  #   "[css]" = {
  #     "editor.defaultFormatter" = "aeschli.vscode-css-formatter";
  #   };
  # };
}
