{ lib, pkgs, ... }: {
  programs.vscode.extensions =
    #
    with pkgs.vscode-marketplace;
    with pkgs.vscode-marketplace-release; [
      ms-python.python
      ms-python.debugpy
      kevinrose.vsc-python-indent
      ms-toolsai.jupyter-renderers
      ms-toolsai.jupyter
    ];

  programs.vscode.userSettings = { };
}
