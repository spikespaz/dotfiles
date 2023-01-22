{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    nil
    alejandra
  ];

  programs.vscode.extensions = with pkgs.vscode-marketplace.vscode; [
    jnoortheen.nix-ide
    kamadorueda.alejandra
  ];

  programs.vscode.userSettings = {
    "nix.enableLanguageServer" = true;
    "nix.serverPath" = lib.getExe pkgs.nil;
    # "nix.formatterPath" = lib.getExe pkgs.alejandra;
    "alejandra.program" = lib.getExe pkgs.alejandra;
    "[nix]" = {
      # appears to be buggy at the moment
      "editor.stickyScroll.enabled" = false;
    };
  };
}
