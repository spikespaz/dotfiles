# DOCUMENTATION
# <https://nix-community.github.io/home-manager/options.html>
# PACKAGE SEARCH
# <https://search.nixos.org/packages>
{ flake, config, lib, ulib, pkgs, nixpkgs, hmModules, ... }:
let
  username = "jacob";
  user = flake.users.${username};
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

  home.sessionVariables = {
    # gtk applications should use filepickers specified by xdg
    GTK_USE_PORTAL = "1";
  };

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

  imports = let inherit (user) services programs;
  in [
    ###############################
    ### MODULES & MISCELLANEOUS ###
    ###############################

    hmModules.homeage

    ### DEFAULT PROGRAMS ###
    user.mimeapps

    ##############################
    ### USER-SPECIFIC PROGRAMS ###
    ##############################

    ### WEB BROWSERS ###
    programs.firefox
    programs.chromium
    programs.microsoft-edge

    ### COMMUNICATION & MESSAGING ###
    programs.mailspring
    # programs.discord.canary
    programs.discord.webcord
    programs.hexchat
    programs.telegram

    ### MEDIA CREATION ###
    programs.obs-studio
    programs.tools.video-editing
    programs.tools.image-editing

    ### MEDIA CONSUMPTION ###
    # programs.spotify

    ### OFFICE & WRITING SOFTWARE ###
    programs.onlyoffice
    # TODO doesn't work
    # programs.apostrophe

    ### TERMINAL EMULATORS ###
    programs.alacritty

    ### CODE EDITORS ###
    programs.vscode.settings
    programs.vscode.languages.bash
    programs.vscode.languages.nix
    programs.vscode.languages.perl
    programs.vscode.languages.rust
    programs.vscode.languages.web
    programs.vscode.languages.yuck
    # programs.vscode.languages.nushell
    programs.vscode.other.marp
    # TODO broken idk why
    # programs.vscode.languages.all
    programs.jetbrains.clion
    programs.jetbrains.goland
    programs.jetbrains.idea
    programs.jetbrains.pycharm
    programs.neovim
    programs.helix
    programs.lapce

    ### DEVELOPMENT TOOLS ###
    programs.git
    programs.java
    programs.rustup

    ### SHELL ENVIRONMENTS ###
    programs.bash
    programs.zsh

    ### CLI UTILITIES ###
    programs.bat
    programs.lsd
    programs.fzf
    programs.gallery-dl

    ### SYSTEM ADMINISTRATION & DIAGNOSTICS ###
    programs.neofetch
    programs.nix-index

    ### VIDEO GAMES ###
    programs.minecraft.prism-launcher

    ### AUTHENTICATION ###
    programs.keepassxc

    ### FILE SHARING ###
    # programs.transmission
    programs.qbittorrent
    programs.filezilla

    ### HARDWARE ###
    # programs.hardware.razer

    ##############################
    ### USER-SPECIFIC SERVICES ###
    ##############################

    ### MEDIA ###
    services.spotify

    ### FILE SYNCHRONIZATION ###
    services.onedrive

    ### DEVICE MANAGEMENT ###
    services.udiskie

    ### SECRET MANAGEMENT ###
    services.keepassxc
  ];
}
