{
  lib,
  pkgs,
  ...
}: {
  programs.vscode.enable = true;

  home.packages = with pkgs; [
    (nerdfonts.override {fonts = ["JetBrainsMono"];})
  ];

  programs.vscode.extensions = with pkgs.vscode-extensions;
    [
      ## Appearances ##
      jdinhlife.gruvbox
      pkief.material-icon-theme

      ## Behaviors ##
      christian-kohler.path-intellisense
    ]
    ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        # For keybind macros
        name = "multi-command";
        publisher = "ryuta46";
        version = "1.6.0";
        sha256 = "sha256-AnHN1wvyVrZRlnOgxBK7xKLcL7SlAEKDcw6lEf+2J2E=";
      }
    ];

  programs.vscode.userSettings = {
    ## Appearances ##

    # the most important setting
    "editor.fontFamily" = "JetBrainsMono Nerd Font";
    "editor.fontSize" = 14;
    "editor.cursorSmoothCaretAnimation" = true;
    "editor.cursorStyle" = "block";

    # scale the ui down
    "window.zoomLevel" = -1;
    # hide the menu bar unless alt is pressed
    "window.menuBarVisibility" = "toggle";
    # colors and icons
    "workbench.colorTheme" = "Gruvbox Dark Hard";
    "workbench.iconTheme" = "material-icon-theme";
    "material-icon-theme.folders.theme" = "classic";
    # the minimap gets in the way
    "editor.minimap.enabled" = false;
    # scroll with an animation
    "editor.smoothScrolling" = true;
    "workbench.list.smoothScrolling" = true;
    "terminal.integrated.smoothScrolling" = true;
    # blink the cursor in terminal
    "terminal.integrated.cursorBlinking" = true;
    # line style cursor in terminal
    "terminal.integrated.cursorStyle" = "line";
    # fix fuzzy text in integrated terminal
    "terminal.integrated.gpuAcceleration" = "on";

    ## Saving and Formatting ##

    # auto-save when the active editor loses focus
    "files.autoSave" = "onFocusChange";
    # format pasted code if the formatter supports a range
    "editor.formatOnPaste" = true;
    # if the plugin supports range formatting always use that
    "editor.formatOnSaveMode" = "modificationsIfAvailable";
    # insert a newline at the end of a file when saved
    "files.insertFinalNewline" = true;
    # trim whitespace trailing at the ends of lines on save
    "files.trimTrailingWhitespace" = true;

    ## VCS Behavior ##

    # prevent pollute history with whitespace changes
    "diffEditor.ignoreTrimWhitespace" = false;

    ## Navigation Behavior ##

    # scrolling in tab bar switches
    "workbench.editor.scrollToSwitchTabs" = true;
    # name of current scope sticks to top of editor pane
    "editor.stickyScroll.enabled" = true;

    ## Miscellaneous ##

    # disable automatic update checking
    "update.mode" = "none";
    # don't re-open everything on start
    "window.restoreWindows" = "none";
    # unsaved files will be "untitled"
    "workbench.editor.untitled.labelFormat" = "name";
    # default hard and soft rulers
    "editor.rulers" = [80 120];
    # fancy features with the integrated terminal
    "terminal.integrated.shellIntegration.enabled" = true;
    # files can be recovered with undo
    "explorer.confirmDelete" = false;
    # set the integrated terminal to use zsh
    "terminal.integrated.defaultProfile.linux" = "zsh";
  };

  programs.vscode.keybindings = let
    formatOnManualSaveOnlyCondition = lib.concatStringsSep " " [
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
    ### FORMAT DOCUMENT ON MANUAL SAVE ONLY ###

    # remove the default action for saving document
    {
      key = "ctrl+s";
      command = "-workbench.action.files.save";
      when = formatOnManualSaveOnlyCondition;
    }
    # formatting behavior identical to the default ctrl+k ctrl+f
    # and the save as normal
    {
      key = "ctrl+s";
      command = "extension.multiCommand.execute";
      args = {
        sequence = [
          "editor.action.formatDocument"
          "workbench.action.files.save"
        ];
      };
      when = formatOnManualSaveOnlyCondition;
    }

    ### END ###

    ### DELETE CURRENT LINE ###

    {
      key = "ctrl+d";
      command = "editor.action.deleteLines";
      when = "textInputFocus && !editorReadonly";
    }

    ### END ###

    ### INSERT TAB CHARACTER ###

    {
      key = "ctrl+k tab";
      command = "type";
      args = {text = "	";};
      when = "editorTextFocus && !editorReadonly";
    }

    ### END ###
  ];
}
