{ lib, pkgs, ... }:
{
  home.sessionVariables = { GDK_SCALE = lib.mkForce 2; };
  programs.vscode.userSettings = { "editor.fontSize" = lib.mkForce 14; };
}
