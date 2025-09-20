profileName:
{ lib, pkgs, ... }: {
  programs.vscode.profiles.${profileName} = {
    extensions = let extensions = pkgs.callPackage ../marketplace.nix { };
    in with extensions.preferReleases; [ mads-hartmann.bash-ide-vscode ];

    userSettings = {
      "[shellscript]" = {
        "editor.tabSize" = 2;
        "editor.insertSpaces" = false;
        "editor.defaultFormatter" = "mads-hartmann.bash-ide-vscode";
      };

      "bashIde.shellcheckPath" = lib.getExe pkgs.shellcheck;

      "bashIde.shfmt.path" = lib.getExe pkgs.shfmt;
      "bashIde.shfmt.binaryNextLine" = true;
      "bashIde.shfmt.caseIndent" = true;
      "bashIde.shfmt.keepPadding" = true;
      "bashIde.shfmt.spaceRedirects" = true;
    };
  };
}
