{ lib, pkgs, ... }: {
  home.packages = with pkgs; [
    shellcheck
  ];

  programs.vscode.extensions = with pkgs.vscode-extensions; [
    mads-hartmann.bash-ide-vscode
    timonwong.shellcheck
  ];

  programs.vscode.userSettings = {
    "[shellscript]" = {
      "editor.tabSize" = 2;
      "editor.insertSpaces" = false;
    };

    "shellcheck.executablePath" = lib.getExe pkgs.shellcheck;
  };
}
