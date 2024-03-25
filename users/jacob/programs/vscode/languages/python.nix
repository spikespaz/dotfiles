{ lib, pkgs, ... }: {
  programs.vscode.extensions =
    let extensions = pkgs.callPackage ../marketplace.nix { };
    in with extensions.preferReleases; [
      ms-python.python
      ms-python.debugpy
      kevinrose.vsc-python-indent
      ms-toolsai.jupyter-renderers
      ms-toolsai.jupyter
    ];

  programs.vscode.userSettings = { };
}
