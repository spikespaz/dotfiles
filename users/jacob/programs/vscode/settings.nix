{ lib, pkgs, ... }: {
  programs.vscode.enable = true;
  programs.vscode.package = let
    super = pkgs.vscode;
    fontPackages = with pkgs; [
      material-design-icons
      (nerdfonts.override { fonts = [ "JetBrainsMono" "Monaspace" ]; })
    ];
  in (pkgs.symlinkJoin {
    inherit (super) name pname version;
    paths = [ super ] ++ fontPackages;
  });

  programs.vscode.enableExtensionUpdateCheck = false;
  programs.vscode.enableUpdateCheck = false;
  programs.vscode.mutableExtensionsDir = false;

  programs.vscode.extensions =
    let extensions = pkgs.callPackage ./marketplace.nix { };
    in with extensions.preferReleases; [
      ## Appearances ##
      # jdinhlife.gruvbox
      monokai.theme-monokai-pro-vscode
      bottledlactose.darkbox
      oderwat.indent-rainbow

      pkief.material-icon-theme

      ## Intelligence ##
      usernamehw.errorlens
      ionutvmi.path-autocomplete
      streetsidesoftware.code-spell-checker

      phind.phind

      ## Version Control ##
      # huizhou.githd
      # mhutchie.git-graph
      phil294.git-log--graph
      github.vscode-github-actions

      ## Collaboration Features
      ms-vsliveshare.vsliveshare

      ## Editor Extension ##
      ryuta46.multi-command
      # sirmspencer.vscode-autohide # This extension is buggy hot garbage.
      sleistner.vscode-fileutils

      ## Basic Config Languages ##
      kdl-org.kdl
      redhat.vscode-yaml
      tamasfe.even-better-toml
    ];

  programs.vscode.userSettings = {
    ## Appearances ##

    # the most important setting
    "editor.fontFamily" = lib.concatMapStringsSep ", " (s: "'${s}'") [
      "Material Design Icons"
      "MonaspiceNe Nerd Font"
      # "JetBrainsMono Nerd Font"
    ];
    # "editor.fontLigatures" = true;
    # "editor.fontLigatures" = lib.concatMapStringsSep ", " (s: "'${s}'") [
    #   "ss01" # == === =/= != !== /= /== ~~ =~ !~
    #   "ss02" # >= <=
    #   "ss03" # -> <- => <!-- --> <~ <~~ <~>
    #   # "ss04" # </ /> </> /\ \/
    #   # "ss05" # |> <|
    #   "ss06" # ## ###
    #   "ss07" # *** /* */ /*/ (* *) (*)
    #   # "ss08" # .= .- ..<
    #   "liga" # <! !! ** :: =: == =! =/ != --
    #   "calt" # // /// && ?? ?. ?: || :: ::: ;; .. ... =~= #= := =:= :> >: :> ..= ==-
    #   # "dlig" # all
    # ];
    "editor.fontSize" = 14;
    "editor.cursorSmoothCaretAnimation" = "explicit";
    "editor.cursorStyle" = "block";
    "editor.cursorBlinking" = "smooth";
    "window.density.editorTabHeight" = "compact";

    # for some reason it is not the same as the editor
    "terminal.integrated.lineHeight" = 1.4;

    # popups are really annoying
    "editor.hover.delay" = 700;

    # colors
    "workbench.colorTheme" = "Darkbox";
    "workbench.colorCustomizations" = {
      "[Monokai Pro (Filter Spectrum)]" = {
        "editorInlayHint.foreground" = "#69676c";
        "editorInlayHint.background" = "#222222";
      };
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

    # scale the ui down
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

    # AutoHide does not cancel the timer if the panel is re-selected,
    # rendering these settings (and the extension) completely useless.
    # "autoHide.sideBarDelay" = 30000; # seconds
    # "autoHide.panelDelay" = 30000; # seconds

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
}
