{
  lib,
  pkgs,
  ...
}: {
  programs.vscode.extensions =
    # (with pkgs.vscode-extensions; [
    #   aeschli.vscode-css-formatter
    # ])
    # ++
    (
      pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "live-server";
          publisher = "ms-vscode";
          version = "0.5.2023010901";
          sha256 = "sha256-gEQ5U6kxBX73jblStDxAIHo5jXLgCfC2WvnsD7XdW38=";
        }
        {
          name = "vscode-css-formatter";
          publisher = "aeschli";
          version = "1.0.2";
          sha256 = "sha256-DFNOeeTm13qWFhkfzcpIXWw/YjWYSKy6bq+YbLWcU5A=";
        }
      ]
    );

  programs.vscode.userSettings = {
    "[css]" = {
      "editor.defaultFormatter" = "aeschli.vscode-css-formatter";
    };
  };
}
