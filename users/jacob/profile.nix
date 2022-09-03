# DOCUMENTATION
# <https://nix-community.github.io/home-manager/options.html>
# PACKAGE SEARCH
# <https://search.nixos.org/packages>
args @ { config, pkgs, nixpkgs, inputs, ... }: let
  programs = import ./programs args;
in {
  ################
  ### PREAMBLE ###
  ################

  # there is a bug in nixpkgs that prevents the global
  # "allow unfree" from working, so instead just specify
  # a callback that says yes every time something asks
  # if it can install a package with a proprietary license
  # <https://github.com/nix-community/home-manager/issues/2942>
  # nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true;

  # fix for some display managers not using ~/.profile
  systemd.user.sessionVariables = config.home.sessionVariables;

  home.stateVersion = "22.05";

  ####################################
  ### BASIC USER ENVIRONMENT SETUP ###
  ####################################

  home.username = "jacob";
  home.homeDirectory = "/home/${config.home.username}";

  xdg.enable = true;
  xdg.userDirs.enable = true;
  xdg.userDirs.createDirectories = true;

  home.sessionVariables = {
    # gtk applications should use filepickers specified by xdg
    GTK_USE_PORTAL = "1";
    # firefox and mozilla software expect wayland
    MOZ_ENABLE_WAYLAND = "1";
  };

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # things that should possibly be a part of the desktop environment
    qalculate-gtk
    onedrive

    # google-fonts
    (nerdfonts.override {
      fonts = [
        "Iosevka"
        "FiraCode"
        "JetBrainsMono"
        "FantasqueSansMono"
      ];
    })

    ###########################
    ### DESKTOP ENVIRONMENT ###
    ###########################

    # Device Configuration
    lxqt.pavucontrol-qt  # Pulse Audio Volume Control
    system-config-printer

    # Dolphin File Manager
    libsForQt5.dolphin
    libsForQt5.dolphin-plugins
    libsForQt5.kio-extras
    libsForQt5.ffmpegthumbs  # Video Thumbnails
    libsForQt5.kimageformats  # Proprieary Image Formats
    resvg  # SVG Thumbnails
    taglib  # Audio File Tags
    libsForQt5.ark  # Archive GUI

    # KDE Utilities
    libsForQt5.kcolorchooser  # Color Chooser
    libsForQt5.kate  # Text Editor
    libsForQt5.kdf  # Disk Usage
    libsForQt5.kompare  # Difference Viewer
    libsForQt5.okular  # Document Viewer
    libsForQt5.print-manager  # Print Manager
    libsForQt5.skanlite  # Lightweight Document Scanner

    # LXQT Utilities
    lxqt.lximage-qt  # Image Viewer
  ];

  imports = [
    ##############################
    ### USER-SPECIFIC SOFTWARE ###
    ##############################

    ### WEB BROWSERS ###
    programs.firefox
    programs.chromium

    ### COMMUNICATION & MESSAGING ###
    programs.mailspring
    programs.discord
    programs.neochat
    programs.hexchat

    ### MEDIA CREATION ###
    programs.obs-studio

    ### OFFICE & WRITING SOFTWARE ###
    programs.onlyoffice
    programs.apostrophe

    ### TERMINAL EMULATORS ###
    programs.alacritty

    ### CODE EDITORS ###
    programs.vscode
    programs.neovim
    programs.helix

    ### DEVELOPMENT TOOLS ###
    programs.git

    ### SHELL ENVIRONMENTS ###
    programs.bash

    ### CLI UTILITIES ###
    programs.bat
    programs.lsd
    programs.fzf
    programs.gallery-dl

    ### SYSTEM ADMINISTRATION & DIAGNOSTICS ###
    programs.neofetch
    programs.wev
    programs.nix-index
  ];
}
