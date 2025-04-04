profileName:
{ lib, pkgs, ... }: {
  programs.vscode.profiles.${profileName} = {
    extensions = let extensions = pkgs.callPackage ../marketplace.nix { };
    in with extensions.preferReleases; [
      mads-hartmann.bash-ide-vscode
      timonwong.shellcheck
      foxundermoon.shell-format
    ];

    userSettings = {
      "[shellscript]" = {
        "editor.tabSize" = 2;
        "editor.insertSpaces" = false;
        "editor.defaultFormatter" = "foxundermoon.shell-format";
      };

      "shellcheck.executablePath" = lib.getExe pkgs.shellcheck;
      "shellformat.path" = lib.getExe pkgs.shfmt;
      "shellformat.flag" = lib.concatStringsSep " " [
        "--indent 0"
        "--binary-next-line"
        "--case-indent"
        "--space-redirects"
        "--keep-padding"
      ];
    };
  };
}
