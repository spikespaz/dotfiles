# DOCUMENTATION
# <https://nix-community.github.io/home-manager/options.html>
# PACKAGE SEARCH
# <https://search.nixos.org/packages>
args@{ self, config, lib, inputs, pkgs, ... }:
let username = "jacob";
in {
  ################
  ### PREAMBLE ###
  ################

  # fix for some display managers not using ~/.profile
  systemd.user.sessionVariables = config.home.sessionVariables;

  home.stateVersion = "22.05";

  ####################################
  ### BASIC USER ENVIRONMENT SETUP ###
  ####################################

  home.username = username;
  home.homeDirectory = "/home/${config.home.username}";

  xdg.enable = true;
  xdg.userDirs.enable = true;
  xdg.userDirs.createDirectories = true;

  programs.home-manager.enable = true;

  # homeage.pkg = pkgs.ragenix;
  homeage.mount = "${config.home.homeDirectory}/.secrets";
  homeage.identityPaths = [ "~/.ssh/id_ed25519" ];
  # homeage.installationType = "activation";

  # should already be enabled at system level
  # fontconfig required to make user-fonts by name
  # todo: figure out how to make ~/.local/share/fonts
  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    BROWSER = "firefox";
    TERMINAL = "alacritty";
    EDITOR = "nvim";
  };

  ##########################
  ### PACKAGES & MODULES ###
  ##########################

  imports = let
    user = lib.importDir' ../shared null;
    programs = user.programs args;
    services = user.services args;
  in [
    ###############################
    ### MODULES & MISCELLANEOUS ###
    ###############################

    inputs.homeage.homeManagerModules.homeage
    (self.tree.scripts.dots pkgs {
      flakeIsWorktree = false;
      flakeBasename = "dotfiles";
    })

    ### DEFAULT PROGRAMS ###
    # user.mimeApps

    ##############################
    ### USER-SPECIFIC PROGRAMS ###
    ##############################

    ### WEB BROWSERS ###
    programs.firefox
    programs.chromium

    ### COMMUNICATION & MESSAGING ###
    programs.thunderbird
    programs.vesktop

    ### MEDIA CREATION ###
    programs.obs-studio
    # programs.handbrake
    programs.ffmpeg
    programs.pinta
    # programs.gimp

    ### MEDIA CONSUMPTION ###
    programs.tidal

    ### OFFICE & WRITING SOFTWARE ###
    programs.libreoffice

    ### TERMINAL EMULATORS ###
    programs.alacritty

    ### CODE EDITORS ###
    programs.vscode.settings
    programs.vscode.keybinds
    programs.vscode.languages.cpp
    programs.vscode.languages.bash
    programs.vscode.languages.nix
    programs.vscode.languages.rust
    programs.vscode.languages.python
    programs.neovim

    ### DEVELOPMENT TOOLS ###
    programs.nix
    programs.git
    programs.java
    programs.rust # Does not contain packages, use devshell.

    ### SHELL ENVIRONMENTS ###
    programs.zsh

    ### CLI UTILITIES ###
    programs.bat
    programs.lsd
    programs.fzf
    programs.jq
    programs.gallery-dl

    ### SYSTEM ADMINISTRATION & DIAGNOSTICS ###
    programs.remmina
    programs.neofetch
    programs.nix-index
    programs.virt-manager

    ### VIDEO GAMES ###
    programs.prism-launcher

    ### AUTHENTICATION ###
    programs.keepassxc

    ### FILE SHARING ###
    # programs.transmission
    programs.qbittorrent
    programs.filezilla
    programs.jellyfin

    ### 3D PRINTING ###
    programs.prusa-slicer

    ##############################
    ### USER-SPECIFIC SERVICES ###
    ##############################

    ### MEDIA ###
    services.playerctl

    ### FILE SYNCHRONIZATION ###
    services.onedrive

    ### DEVICE MANAGEMENT ###
    services.udiskie
    services.easyeffects

    ### SECRET MANAGEMENT ###
    services.keepassxc
  ];
}
