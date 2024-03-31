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
    user = lib.importDir' ./. "profile.nix";
    programs = user.programs args;
    services = user.services args;
  in [
    ###############################
    ### MODULES & MISCELLANEOUS ###
    ###############################

    inputs.homeage.homeManagerModules.homeage
    (self.tree.scripts.dots pkgs {
      flakeIsWorktree = true;
      flakeBasename = "dotfiles.git";
    })

    ### DEFAULT PROGRAMS ###
    # user.mimeApps

    ##############################
    ### USER-SPECIFIC PROGRAMS ###
    ##############################

    ### WEB BROWSERS ###
    programs.firefox
    programs.chromium
    programs.microsoft-edge

    ### COMMUNICATION & MESSAGING ###
    # programs.mailspring
    programs.thunderbird
    # programs.discord.canary
    # programs.discord.webcord
    # programs.armcord
    programs.vesktop
    programs.hexchat
    programs.telegram
    programs.matrix
    programs.mattermost

    ### MEDIA CREATION ###
    programs.obs-studio
    programs.handbrake
    programs.ffmpeg
    programs.kdenlive
    programs.shotcut
    programs.pinta
    programs.gimp

    ### MEDIA CONSUMPTION ###
    # programs.spotify
    programs.tidal

    ### OFFICE & WRITING SOFTWARE ###
    programs.onlyoffice
    programs.libreoffice
    # TODO doesn't work
    # programs.apostrophe

    ### TERMINAL EMULATORS ###
    programs.alacritty

    ### CODE EDITORS ###
    programs.vscode.settings
    programs.vscode.keybinds
    programs.vscode.languages.cpp
    programs.vscode.languages.bash
    programs.vscode.languages.nix
    programs.vscode.languages.perl
    programs.vscode.languages.rust
    programs.vscode.languages.web
    programs.vscode.languages.yuck
    programs.vscode.languages.python
    programs.vscode.languages.nushell
    programs.vscode.other.marlin
    programs.vscode.other.marp
    # TODO broken idk why
    # programs.vscode.languages.all
    # programs.jetbrains.clion
    # programs.jetbrains.goland
    # programs.jetbrains.idea
    # programs.jetbrains.pycharm
    # programs.rstudio
    programs.neovim
    programs.helix
    programs.lapce

    ### DEVELOPMENT TOOLS ###
    programs.nix
    programs.git
    programs.java
    programs.rust # Does not contain packages, use devshell.

    ### SHELL ENVIRONMENTS ###
    programs.zsh
    programs.nushell

    ### CLI UTILITIES ###
    programs.bat
    programs.lsd
    programs.fzf
    programs.jq
    programs.gallery-dl

    ### SYSTEM ADMINISTRATION & DIAGNOSTICS ###
    programs.remmina
    programs.anydesk
    programs.rustdesk
    programs.neofetch
    programs.nix-index
    programs.virt-manager

    ### VIDEO GAMES ###
    programs.minecraft.prism-launcher
    programs.moonlight
    programs.steam

    ### AUTHENTICATION ###
    programs.keepassxc

    ### FILE SHARING ###
    # programs.transmission
    programs.qbittorrent
    programs.filezilla
    programs.jellyfin

    ### 3D PRINTING ###
    programs.openscad
    programs.prusa-slicer
    # disabled until <https://github.com/NixOS/nixpkgs/pull/225817> is merged
    # programs.super-slicer
    programs.cura

    ### HARDWARE ###
    # programs.hardware.razer

    ##############################
    ### USER-SPECIFIC SERVICES ###
    ##############################

    ### BACKGROUND SYNC & NOTIFICATIONS ###
    # services.thunderbird

    ### MEDIA ###
    services.playerctl
    # services.spotify

    ### FILE SYNCHRONIZATION ###
    services.onedrive

    ### DEVICE MANAGEMENT ###
    services.udiskie
    services.easyeffects

    ### SECRET MANAGEMENT ###
    services.keepassxc
  ];
}
