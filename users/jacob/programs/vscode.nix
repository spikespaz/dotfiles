{ pkgs, inputs, ... }: {
  home.packages = with pkgs; [
    ### FONTS ###
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })

    ### LANGUAGE SERVERS ###
    # Perl Language Server
    perlPackages.PLS
    # Nix Language Server
    inputs.nil.packages.${pkgs.system}.default
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
    
    ## VCS Behavior ##

    # prevent pollute history with whitespace changes
    "diffEditor.ignoreTrimWhitespace" = false;

    ## Navigation Behavior ##

    # scrolling in tab bar switches
    "workbench.editor.scrollToSwitchTabs" = true;
    # name of current scope sticks to top of editor pane
    "editor.experimental.stickyScroll.enabled" = true;

    ## Language Servers ##

    "perl.pls" = "${pkgs.perlPackages.PLS}/bin/pls";

    "nix.enableLanguageServer" = true;
    "nix.serverPath" = "${inputs.nil.packages.${pkgs.system}.default}/bin/nil";
  
    ## Miscellaneous ##

    # don't re-open everything on start
    "window.restoreWindows" = "none";
    # default hard and soft rulers
    "editor.rulers" = [ 80 120 ];
    # fancy features with the integrated terminal
    "terminal.integrated.shellIntegration.enabled" = true;
    # files can be recovered with undo
    "explorer.confirmDelete" = false;

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
}
