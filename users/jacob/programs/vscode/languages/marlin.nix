{ lib, pkgs, ... }: {
  programs.vscode.extensions = with pkgs.vscode-extensions;
    with pkgs.vscode-marketplace;
    with pkgs.vscode-marketplace-release; [
      marlinfirmware.auto-build
      ms-vscode.cpptools
      platformio.platformio-ide
    ];

  home.packages = [ pkgs.platformio ];

  programs.vscode.userSettings = { "auto-build.defaultEnv.update" = false; };
}
