profileName:
{ lib, pkgs, config, ... }: {
  programs.vscode.profiles.${profileName} = {
    extensions = let extensions = pkgs.callPackage ../marketplace.nix { };
    in with extensions.preferReleases;
    [
      #
      thenuprojectcontributors.vscode-nushell-lang
    ];

    userSettings = {
      "nushellLanguageServer.nushellExecutablePath" =
        lib.getExe config.programs.nushell.package;
    };
  };
}
