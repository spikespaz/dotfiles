{ config, lib, pkgs, ... }:
let
  dictionary = [ "builtins" "pkgs" "concat" "nixos" "nixpkgs" ];
  fontIsEnabled = familyName:
    (builtins.match ".*${familyName}.*"
      config.programs.vscode.userSettings."editor.fontFamily") != [ ];
  monaspiceLigatures = fontIsEnabled "MonaspiceNe Nerd Font";
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
    # "nix.serverPath" = lib.getExe pkgs.nil;
    # "nix.serverSettings".nil = {
    #   formatting.command = [ "nix" "fmt" "--" "--" ];
    # };
    "nix.serverPath" = lib.getExe pkgs.nixd;
    "nix.serverSettings".nixd = {
      formatting.command = [ "nix" "fmt" "--" "--" ];
    };
    "[nix]" = {
      # appears to be buggy at the moment
      "editor.stickyScroll.enabled" = false;
      # allow paths to be auto-completed
      "path-autocomplete.triggerOutsideStrings" = true;
      # don't add a trailing slash for dirs
      "path-autocomplete.enableFolderTrailingSlash" = false;

      "editor.fontLigatures" = lib.concatMapStringsSep ", " (s: "'${s}'") [
        "ss01" # == === =/= != !== /= /== ~~ =~ !~
        "ss02" # >= <=
        # "ss03" # -> <- => <!-- --> <~ <~~ <~>
        # "ss04" # </ /> </> /\ \/
        # "ss05" # |> <|
        "ss06" # ## ###
        "ss07" # *** /* */ /*/ (* *) (*)
        # "ss08" # .= .- ..<
        "liga" # <! !! ** :: =: == =! =/ != --
        # "calt" # // /// && ?? ?. ?: || :: ::: ;; .. ... =~= #= := =:= :> >: :> ..= ==-
        # "dlig" # all
      ];
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
