{ lib, pkgs, ... }: {
  programs.vscode.extensions =
    let extensions = pkgs.callPackage ../marketplace.nix { };
    in with extensions.preferReleases; [
      pkgs.vscode-extensions.ms-vscode.cpptools # wrapped by nixpkgs
      marlinfirmware.auto-build
      platformio.platformio-ide
    ];

  home.packages = [ pkgs.platformio ];

  programs.vscode.userSettings = { "auto-build.defaultEnv.update" = false; };
}
