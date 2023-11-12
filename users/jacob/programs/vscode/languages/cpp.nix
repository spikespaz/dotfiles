{ lib, pkgs, ... }: {
  home.packages = [ pkgs.rust-analyzer pkgs.slint-lsp ];

  programs.vscode.extensions =
    #
    with pkgs.vscode-marketplace;
    with pkgs.vscode-marketplace-release; [
      llvm-vs-code-extensions.vscode-clangd
      ms-vscode.cmake-tools
      pkgs.vscode-extensions.vadimcn.vscode-lldb
    ];

  programs.vscode.userSettings = {
    "[rust]" = {
      "editor.fontLigatures" = true;

      "editor.formatOnSave" = true;
    };

  };
}
