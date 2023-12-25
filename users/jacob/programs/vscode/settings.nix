{ lib, pkgs, ... }: {
  programs.vscode.enable = true;
  programs.vscode.package = let
    super = pkgs.vscode;
    fontPackages = with pkgs; [
      material-design-icons
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
  in (pkgs.symlinkJoin {
    inherit (super) name pname version;
    paths = [ super ] ++ fontPackages;

    # FIXME
    # Can be removed when this issue is closed:
    # <https://github.com/microsoft/vscode/issues/184124#issuecomment-1802930021>
    #
    # Another solution is:
    # <https://github.com/microsoft/vscode/issues/181533#issuecomment-1597187136>
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/code \
        --add-flags --disable-gpu-sandbox
    '';
  });

  programs.vscode.enableExtensionUpdateCheck = false;
  programs.vscode.enableUpdateCheck = false;
  programs.vscode.mutableExtensionsDir = false;

  programs.vscode.extensions =
    #
    with pkgs.vscode-marketplace;
    with pkgs.vscode-marketplace-release; [
      ## Appearances ##
      # jdinhlife.gruvbox
      monokai.theme-monokai-pro-vscode
      # teeseal.ayu-legacy
      # be5invis.theme-railgun
      # origamid.origamid-next
      # sainnhe.sonokai
      # dimitarnonov.jellybeans-theme
      oderwat.indent-rainbow

      pkief.material-icon-theme

      ## Intelligence ##
      usernamehw.errorlens
      ionutvmi.path-autocomplete
      streetsidesoftware.code-spell-checker

      ## Version Control ##
      huizhou.githd
      mhutchie.git-graph

      ## Editor Extension ##
      ryuta46.multi-command
      sirmspencer.vscode-autohide
      sleistner.vscode-fileutils

      ## Basic Config Languages ##
      kdl-org.kdl
      redhat.vscode-yaml
      tamasfe.even-better-toml
    ];

  ## Gruvbox Dark Hard
  #
  # Hard to go wrong with this theme, has good contrast and balanced hues.
  # Unfortunately, I've been using it the longest, so it feels boring.
  # Strings in some languages are far too prominent--this is probably the
  # fault of the grammar, but nevertheless, I'm ready for a change.

  ## Railgun Chroma
  #
  # This theme looks really good. The colors are well-chosen,
  # and I like that it leans on the warmer side of the spectrum.
  # Almost like a rich espresso, not pitch black, and not blazing.
  # I just wish the colors were lighter, because they are a little hard to see.
  # This could easily be my favorite theme if text were more visible.
  # TODO fork it, increase brightness in LAB colorspace.

  ## Ayu Dark (Legacy)
  #
  # This theme has *perfect* vibrancy, well balanced colors, and excellent
  # contrast and readability. Comments are pale though, and considering
  # they are often the most important lines in a sea of code,
  # it would be nice if they were slightly more emphasized.
  # One minor nitpick is the navy-blue background:
  # the foreground colors would be complimented better
  # if the background were slightly less saturated, and more dark.
  # Love the cursor color.

  programs.vscode.userSettings = {
    ## Appearances ##

    # the most important setting
    "editor.fontFamily" = lib.concatMapStringsSep ", " (s: "'${s}'") [
      "Material Design Icons"
      "JetBrainsMono Nerd Font"
    ];
    "editor.fontSize" = 13;
    "editor.cursorSmoothCaretAnimation" = "explicit";
    "editor.cursorStyle" = "block";

    # popups are really annoying
    "editor.hover.delay" = 700;

    # colors
    "workbench.colorTheme" = "Monokai Pro (Filter Spectrum)";
    "workbench.colorCustomizations" = {
      "[Monokai Pro (Filter Spectrum)]" = {
        "editorInlayHint.foreground" = "#69676c";
        "editorInlayHint.background" = "#222222";
      };
      "[Sonokai Espresso]" = { "editor.background" = "#211e1d"; };
    };

    # hide the default indentation guides to make way for the extension
    "editor.guides.indentation" = false;
    # only color the lines, not the whitespace characters
    "indentRainbow.indicatorStyle" = "light";
    # indent guide colors generated from a count
    "indentRainbow.colors" = let
      count = 12;
      saturation = 0.425;
      lightness = 0.35;
      alpha = 0.5;
    in map (hue:
      "hsla(${
        lib.concatStringsSep "," [
          (toString hue)
          (lib.toPercent 1 saturation)
          (lib.toPercent 1 lightness)
          (toString alpha)
        ]
      })") (lib.genList (i: (360 / count) * i) count);

    # icons
    "workbench.iconTheme" = "material-icon-theme";
    "material-icon-theme.folders.theme" = "classic";

    # title
    "window.titleSeparator" = " - ";
    "window.title" = lib.concatMapStrings (s: "\${${s}}") [
      "rootName"
      "separator"
      "activeEditorMedium"
      "separator"
      "appName"
    ];

    # # scale the ui down
    # "window.zoomLevel" = -1;
    # hide the menu bar unless alt is pressed
    "window.menuBarVisibility" = "toggle";
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

    # hide the action bar, I know the keybinds
    "workbench.activityBar.location" = "hidden";
    # put the sidebar on the right so that text doesn't jump
    "workbench.sideBar.location" = "right";
    # no delay when automatically hiding the sidebar or panels
    "autoHide.sideBarDelay" = 0;
    "autoHide.panelDelay" = 0;

    # show vcs changes and staged changes as a tree
    "scm.defaultViewMode" = "tree";

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

    # allow 6 more characters from default 50 in commit subject
    "git.inputValidationSubjectLength" = 56;

    # prevent pollute history with whitespace changes
    "diffEditor.ignoreTrimWhitespace" = false;
    # show blames at the end of current line
    "gitblame.inlineMessageEnabled" = true;
    # blame message format for inline, remove "Blame"
    "gitblame.inlineMessageFormat" = "\${author.name} (\${time.ago})";
    "gitblame.inlineMessageNoCommit" = "Uncommitted changes";
    # blame message format for status bar
    "gitblame.statusBarMessageFormat" = "Blame \${author.name} (\${time.ago})";
    "gitblame.statusBarMessageNoCommit" = "Uncommitted changes";
    # open the changes in browser when clicking blame on status bar
    "gitblame.statusBarMessageClickAction" = "Open tool URL";

    ## Navigation Behavior ##

    # scrolling in tab bar switches
    "workbench.editor.scrollToSwitchTabs" = true;
    # name of current scope sticks to top of editor pane
    "editor.stickyScroll.enabled" = true;
    # larger indent
    "workbench.tree.indent" = 16;

    ## Intelligence Features ##

    # show the errors shortly after saving
    "errorLens.onSaveTimeout" = 200;
    # space between EOL and error
    "errorLens.margin" = "1em";
    # do not show error messages on lines in merge conflict blocks
    "errorLens.enabledInMergeConflict" = false;
    # diagnostic levels to show, removed "info"
    "errorLens.enabledDiagnosticLevels" = [ "error" "warning" ];
    # slower updates but less buggy
    "errorLens.delayMode" = "debounce";

    # don't add a trailing slash for dirs
    "path-autocomplete.enableFolderTrailingSlash" = false;

    ## Miscellaneous ##

    # disable automatic update checking
    "update.mode" = "none";
    # don't re-open everything on start
    "window.restoreWindows" = "none";
    # don't show the welcome page
    "workbench.startupEditor" = "none";
    # unsaved files will be "untitled"
    "workbench.editor.untitled.labelFormat" = "name";
    # default hard and soft rulers
    "editor.rulers" = [ 80 120 ];
    # files can be recovered with undo
    "explorer.confirmDelete" = false;
    # set the integrated terminal to use zsh
    "terminal.integrated.defaultProfile.linux" = "zsh";
    # never ask to open parent git repo if one-off
    "git.openRepositoryInParentFolders" = "never";

    ## Temporarily Disabled ###

    # fancy features with the integrated terminal
    # this makes the terminal horribly slow
    # "terminal.integrated.shellIntegration.enabled" = true;
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
        sequence =
          [ "editor.action.formatDocument" "workbench.action.files.save" ];
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
      args = { text = "	"; };
      when = "editorTextFocus && !editorReadonly";
    }

    ### END ###

    ### FOCUS THE TERMINAL ###

    # {
    #   key = "shift+`";
    #   command = "workbench.action.terminal.focus";
    # }

    ### END ###

    ### FOCUS ON FILE EXPLORER SIDEBAR ###

    {
      key = "ctrl+e";
      command = "-workbench.action.quickOpen";
    }
    {
      key = "ctrl+e";
      command = "workbench.files.action.focusFilesExplorer";
    }

    ### END ###
  ];
}
