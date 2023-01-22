{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    shellcheck
    shfmt
  ];

  programs.vscode.extensions = with pkgs.vscode-marketplace.vscode; [
    mads-hartmann.bash-ide-vscode
    timonwong.shellcheck
    foxundermoon.shell-format
  ];

  programs.vscode.userSettings = {
    "[shellscript]" = {
      "editor.tabSize" = 2;
      "editor.insertSpaces" = false;
    };

    "shellcheck.executablePath" = lib.getExe pkgs.shellcheck;
    "shellformat.path" = lib.getExe pkgs.shfmt;
    "shellformat.flag" = lib.concatStringsSep " " [
      "--indent 0"
      "--binary-next-line"
      "--switch-case-indent"
      "--space-redirects"
      "--keep-padding"
    ];
  };
}
