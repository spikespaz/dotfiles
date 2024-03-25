{ lib, pkgs, ... }:
let dictionary = [ "builtins" "pkgs" "concat" "nixos" "nixpkgs" ];
in {
  programs.vscode.extensions =
    let extensions = pkgs.callPackage ../marketplace.nix { };
    in with extensions.preferReleases; [
      jnoortheen.nix-ide
      # kamadorueda.alejandra
      arrterian.nix-env-selector
      ionutvmi.path-autocomplete
    ];

  programs.vscode.userSettings = {
    "nix.enableLanguageServer" = true;
    "nix.serverPath" = lib.getExe pkgs.nil;
    "nix.serverSettings".nil = {
      formatting.command = [ "nix" "fmt" "--" "--" ];
    };
    "[nix]" = {
      # appears to be buggy at the moment
      "editor.stickyScroll.enabled" = false;
      # allow paths to be auto-completed
      "path-autocomplete.triggerOutsideStrings" = true;
      # don't add a trailing slash for dirs
      "path-autocomplete.enableFolderTrailingSlash" = false;
    };

    "cSpell.languageSettings" = [{
      languageId = "nix";
      dictionaries = [ "nix" ];
    }];

    "cSpell.customDictionaries" = {
      nix = {
        path = (pkgs.writeText "dictionary-nix"
          (lib.concatStringsSep "\n" dictionary)).outPath;
        description = "Extra words for the Nix language";
        scope = "user";
      };
    };
  };
}
