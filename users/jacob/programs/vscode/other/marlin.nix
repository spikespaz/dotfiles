profileName:
{ lib, pkgs, ... }: {
  programs.vscode.profiles.${profileName} = {
    extensions = let extensions = pkgs.callPackage ../marketplace.nix { };
    in with extensions.preferReleases; [
      pkgs.vscode-extensions.ms-vscode.cpptools # wrapped by nixpkgs
      marlinfirmware.auto-build
      platformio.platformio-ide
    ];

    userSettings = {
      "auto-build.defaultEnv.update" = false;
      "platformio-ide.useBuiltinPIOCore" = false;
      "platformio-ide.customPATH" = lib.makeBinPath [ pkgs.platformio ];
    };
  };
}
