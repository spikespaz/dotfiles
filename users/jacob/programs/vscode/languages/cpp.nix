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
    "cmake.showOptionsMovedNotification" = false;
    "cmake.cmakePath" = lib.getExe pkgs.cmake;
    # IntelliSense from Microsoft conflicts with clangd
    "C_Cpp.intelliSenseEngine" = "disabled";
    "clangd.path" = lib.getExe' pkgs.clang-tools "clangd";
  };
}
