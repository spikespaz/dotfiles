{
  lib,
  pkgs,
  ...
}: let
  dictionary = [
    "builtins"
    "pkgs"
    "concat"
    "nixos"
    "nixpkgs"
  ];
in {
  programs.vscode.extensions = with pkgs.vscode-marketplace; [
    jnoortheen.nix-ide
    # kamadorueda.alejandra
  ];

  programs.vscode.userSettings = {
    "nix.enableLanguageServer" = true;
    "nix.serverPath" = lib.getExe pkgs.nil;
    "nix.serverSettings".nil = {
      formatting.command = [(lib.getExe pkgs.nixfmt)];
    };
    # "nix.formatterPath" = lib.getExe pkgs.alejandra;
    # "alejandra.program" = lib.getExe pkgs.alejandra;
    "[nix]" = {
      # appears to be buggy at the moment
      "editor.stickyScroll.enabled" = false;
    };

    "cSpell.languageSettings" = [
      {
        languageId = "nix";
        dictionaries = ["nix"];
      }
    ];

    "cSpell.customDictionaries" = {
      nix = {
        path = (pkgs.writeText "dictionary-nix" (lib.concatStringsSep "\n" dictionary)).outPath;
        description = "Extra words for the Nix language";
        scope = "user";
      };
    };
  };
}
