{ lib, pkgs, nil, ... }: {
  home.packages = with pkgs; [
    ### FONTS ###
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })

    ### LANGUAGE SERVERS ###
    # Perl Language Server
    perlPackages.PLS
    # Nix Language Server
    nil.pkgs.default
  ];

  programs.vscode.extensions = with pkgs.vscode-extensions; [
    # Theme
    jdinhlife.gruvbox
    # pkief.material-icon-theme

    # Language Clients
    # fractalboy.pls  # Perl
    jnoortheen.nix-ide  # Nix
    rust-lang.rust-analyzer # Rust
  ];

  programs.vscode.userSettings = {
    ## Appearances ##

    # the most important setting
    "editor.fontFamily" = "JetBrainsMono Nerd Font";
    "editor.fontSize" = 14;

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

    ## Language Servers ##

    "perl.pls" = "${pkgs.perlPackages.PLS}/bin/pls";

    "nix.enableLanguageServer" = true;
    "nix.serverPath" = "${nil.pkgs.default}/bin/nil";

    ## Miscellaneous ##

    # don't re-open everything on start
    "window.restoreWindows" = "none";
    # unsaved files will be "untitled"
    "workbench.editor.untitled.labelFormat" = "name";
    # default hard and soft rulers
    "editor.rulers" = [ 80 120 ];
    # fancy features with the integrated terminal
    "terminal.integrated.shellIntegration.enabled" = true;
    # files can be recovered with undo
    "explorer.confirmDelete" = false;

    ## Language Specific -- Shell ##

    "[shellscript]" = {
      "editor.tabSize" = 2;
      "editor.insertSpaces" = false;
    };

    ## Language Specific -- Rust ##

    "[rust]" = {
      "editor.fontLigatures" = true;

      "editor.formatOnSave" = true;
    };

    # use clippy over cargo check
    "rust-analyzer.checkOnSave.command" = "clippy";

    # use nightly range formatting, should be faster
    "rust-analyzer.rustfmt.rangeFormatting.enable" = true;

    # show references for everything
    "rust-analyzer.hover.actions.references.enable" = true;
    "rust-analyzer.lens.references.adt.enable" = true;
    "rust-analyzer.lens.references.enumVariant.enable" = true;
    "rust-analyzer.lens.references.method.enable" = true;
    "rust-analyzer.lens.references.trait.enable" = true;

    # enforce consistent imports everywhere
    "rust-analyzer.imports.granularity.enforce" = true;
    "rust-analyzer.imports.granularity.group" = "module";
    "rust-analyzer.imports.prefix" = "self";

    # show hints for elided lifetimes
    "rust-analyzer.inlayHints.lifetimeElisionHints.enable" = "always";  # or 'skip_trivial'
    # "rust-analyzer.inlayHints.lifetimeElisionHints.useParameterNames" = true;
  };

  programs.vscode.keybindings = let
    formatDocumentOnManualSaveOnlyCondition = lib.concatStringsSep " " [
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
    {  # remove the default action for saving document
        "key" = "ctrl+s";
        "command" = "-workbench.action.files.save";
        "when" = formatDocumentOnManualSaveOnlyCondition;
    }
    {  # formatting behavior identical to the default ctrl+k ctrl+f
        "key" = "ctrl+s";
        "command" = "editor.action.formatDocument";
        "when" = formatDocumentOnManualSaveOnlyCondition;
    }
    {  # re-introduce default save action, but in new order after format
        "key" = "ctrl+s";
        "command" = "workbench.action.files.save";
        "when" = formatDocumentOnManualSaveOnlyCondition;
    }
    ### END ###
  ];
}
