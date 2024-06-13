{ lib, ... }:
let
  groups.formatOnManualSave = let
    when = lib.concatStringsSep " " [
      # manually saving should only format when auto-saving is enabled
      # in some form, and when the file doesn't already
      # get formatted on every save
      "config.editor.autoSave != off"
      "&& !config.editor.formatOnSave"
      # any other clauses match the default
      # ctrl+k ctrl+f manual format command
      "&& editorHasDocumentFormattingProvider"
      "&& editorTextFocus"
      "&& !editorReadonly"
      "&& !inCompositeEditor"
    ];
  in [
    # remove the default action for saving document
    {
      key = "ctrl+s";
      command = "-workbench.action.files.save";
      inherit when;
    }
    # formatting behavior identical to the default ctrl+k ctrl+f
    # and the save as normal
    {
      key = "ctrl+s";
      command = "extension.multiCommand.execute";
      args = {
        sequence =
          [ "editor.action.formatDocument" "workbench.action.files.save" ];
      };
      inherit when;
    }
  ];
in {
  programs.vscode.keybindings = lib.flatten [
    ### FORMAT DOCUMENT ON MANUAL SAVE ONLY ###
    groups.formatOnManualSave

    ### DELETE CURRENT LINE ###
    {
      key = "ctrl+d";
      command = "editor.action.deleteLines";
      when = "textInputFocus && !editorReadonly";
    }

    ### INSERT TAB CHARACTER ###
    {
      key = "ctrl+k tab";
      command = "type";
      args = { text = "	"; };
      when = "editorTextFocus && !editorReadonly";
    }

    ### FOCUS ON FILE EXPLORER SIDEBAR ###
    {
      key = "ctrl+e";
      command = "-workbench.action.quickOpen";
    }
    {
      key = "ctrl+e";
      command = "workbench.files.action.focusFilesExplorer";
    }
  ];
}
