{
  lib,
  pkgs,
  ...
}: {
  programs.vscode.extensions = with pkgs.vscode-marketplace; [
    jnoortheen.nix-ide
    # kamadorueda.alejandra
  ];

  programs.vscode.userSettings = {
    "nix.enableLanguageServer" = true;
    "nix.serverPath" = lib.getExe pkgs.nil;
    "nix.serverSettings".nil = {
      formatting.command = [(lib.getExe pkgs.alejandra)];
    };
    # "nix.formatterPath" = lib.getExe pkgs.alejandra;
    # "alejandra.program" = lib.getExe pkgs.alejandra;
    "[nix]" = {
      # appears to be buggy at the moment
      "editor.stickyScroll.enabled" = false;
    };
  };
}
