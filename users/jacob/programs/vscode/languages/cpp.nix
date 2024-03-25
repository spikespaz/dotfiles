{ lib, pkgs, ... }: {
  home.packages = [ pkgs.rust-analyzer pkgs.slint-lsp ];

  programs.vscode.extensions =
    let extensions = pkgs.callPackage ../marketplace.nix { };
    in with extensions.preferReleases; [
      llvm-vs-code-extensions.vscode-clangd
      pkgs.vscode-extensions.ms-vscode.cmake-tools # wrapped by nixpkgs
      pkgs.vscode-extensions.vadimcn.vscode-lldb # wrapped by nixpkgs
    ];

  programs.vscode.userSettings = {
    "cmake.showOptionsMovedNotification" = false;
    "cmake.cmakePath" = lib.getExe pkgs.cmake;
    # IntelliSense from Microsoft conflicts with clangd
    "C_Cpp.intelliSenseEngine" = "disabled";
    "clangd.path" = lib.getExe' pkgs.clang-tools "clangd";
  };
}
