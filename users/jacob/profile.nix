# DOCUMENTATION
# <https://nix-community.github.io/home-manager/options.html>
# PACKAGE SEARCH
# <https://search.nixos.org/packages>
{ config, pkgs, nixpkgs, inputs, ... }:
{
  ################
  ### PREAMBLE ###
  ################

  imports = [ ../user_lib.nix ];

  # <https://github.com/nix-community/home-manager/issues/2942>
  # nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true;

  home.stateVersion = "22.05";

  ###################
  ### BASIC SETUP ###
  ###################

  home.username = "jacob";
  home.homeDirectory = "/home/${config.home.username}";

  xdg.enable = true;
  xdg.userDirs.enable = true;
  xdg.userDirs.createDirectories = true;

  ##############################
  ### MISCELLANEOUS SOFTWARE ###
  ##############################

  # System Management

  programs.home-manager.enable = true;

  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
  };

  # Diagnostic Tools

  userPackages.diagnostics = with pkgs; [
    wev
    neofetch
  ];

  # Communication & Messaging

  userPackages.communication = with pkgs; [
    thunderbird
    discord
    neochat
  ];

  programs.hexchat.enable = true;

  # Office Software

  userPackages.office = with pkgs; [
    onlyoffice-bin
  ];

  # Content Sharing

  programs.obs-studio.enable = true;


  ###########################
  ### DESKTOP ENVIRONMENT ###
  ###########################

  userPackages.desktop = with pkgs; [
    # Themes
    materia-kde-theme
  ];

  # enable automatic-mounting of new drives
  services.udiskie = {
    enable = true;
    tray = "never";
  };

  # configure the wm
  xdg.configFile."hypr/hyprland.conf".source = ./configs/hyprland.conf;

  # specify packages to use for gtk theming
  gtk = {
    enable = true;

    cursorTheme.package = pkgs.quintom-cursor-theme;
    cursorTheme.name = "Quintom_Ink";

    iconTheme.package = pkgs.papirus-icon-theme;
    iconTheme.name = "Papirus-Dark";

    theme.package = pkgs.materia-theme;
    theme.name = "Materia-dark-compact";
  };

  # set the kvantum theme, still needs qt5ct to be manually configured
  # expects pkgs.materia-kde-theme
  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=MateriaDark
  '';

  ####################
  ### WEB BROWSERS ###
  ####################
  
  programs.firefox.enable = true;

  programs.chromium.enable = true;

  #########################
  ### DEVELOPMENT TOOLS ###
  #########################

  userPackages.development = with pkgs; [
    # Perl Language Server
    perlPackages.PLS
    # Nix Language Server
    inputs.nil.packages.${pkgs.system}.default
  ];

  programs.git = {
    enable = true;
    userName = "Jacob Birkett";
    userEmail = "jacob@birkett.dev";

    # better looking diffs
    delta.enable = true;
  };

  ####################
  ### CODE EDITORS ###
  ####################

  programs.vscode = {
    enable = true;

    extensions = with pkgs.vscode-extensions; [
      # Theme
      jdinhlife.gruvbox
      # pkief.material-icon-theme

      # Language Clients
      # fractalboy.pls  # Perl
      jnoortheen.nix-ide  # Nix
      rust-lang.rust-analyzer # Rust
    ];

    userSettings = {
      ## Appearances ##

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
      
      ## VCS Behavior ##

      # prevent pollute history with whitespace changes
      "diffEditor.ignoreTrimWhitespace" = false;

      ## Navigation Behavior ##

      # scrolling in tab bar switches
      "workbench.editor.scrollToSwitchTabs" = true;
      # name of current scope sticks to top of editor pane
      "editor.experimental.stickyScroll.enabled" = true;

      ## Language Servers ##

      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${inputs.nil.packages.${pkgs.system}.default}/bin/nil";
    
      ## Miscellaneous ##

      # don't re-open everything on start
      "window.restoreWindows" = "none";
      # default hard and soft rulers
      "editor.rulers" = [ 80 120 ];
      # fancy features with the integrated terminal
      "terminal.integrated.shellIntegration.enabled" = true;

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
  };

  programs.helix.enable = true;

  programs.neovim.enable = true;

  #########################
  ### GENERIC CLI TOOLS ###
  #########################

  userPackages.cli = with pkgs; [
    # Bash Line Editor
    blesh
  ];

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      source "${pkgs.blesh}/share/ble.sh"
    '';
    historyIgnore = [
      "reboot"
      "exit"
    ];
  };

  # cat with wings
  programs.bat = {
    enable = true;
    config.theme = "gruvbox-dark";
  };

  # colorized ls
  # programs.exa.enable = true

  # iconified and colorized ls
  programs.lsd.enable = true;

  # fuzzy finder
  programs.fzf.enable = true;
}

# ========
# This function is for prepending the Hyprland config with environment variables.
# No shell session seemed to respect these.
# ========
#
# let
#   mkHyprEnvVars = { vars, index ? 0, head ? "" }:
#     if index < builtins.length (builtins.attrNames vars) then
#       mkHyprEnvVars {
#         inherit vars;
#         index = index + 1;
#         head = head + "exec-once=export ${builtins.elemAt (builtins.attrNames vars) index}='${builtins.toString (builtins.elemAt (builtins.attrValues vars) index)}'\n";
#       }
#     else
#       head + "\n";
# in
#
# --------
#
# xdg.configFile."hypr/hyprland.conf".text =
#   (mkHyprEnvVars { vars = config.home.sessionVariables; })
#   + (builtins.readFile ./configs/hyprland.conf);
#
# ========
# This should have made all variables accessible to programs whom do not respect `~/.profile`.
# It appears to change nothing.
# ========
#
# home.sessionVariables = {
#   QT_QPA_PLATFORM = "wayland";
#   #XDG_CURRENT_DESKTOP = "sway"
#   #XDG_SESSION_DESKTOP = "sway"
#   #XDG_CURRENT_SESSION_TYPE = "wayland"
#   QT_QPA_PLATFORMTHEME = "qt5ct";
#   QT_STYLE_OVERRIDE = "kvantum";
#   GTK_USE_PORTAL = 1;
#   MOZ_ENABLE_WAYLAND = 1;
#   _JAVA_AWT_WM_NONREPARENTING = 1;
#   XCURSOR_SIZE = 24;
# };
#
# --------
#
# pam.sessionVariables = config.home.sessionVariables;
#
# ========
