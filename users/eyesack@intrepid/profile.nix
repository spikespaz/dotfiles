# DOCUMENTATION
# <https://nix-community.github.io/home-manager/options.html>
# PACKAGE SEARCH
# <https://search.nixos.org/packages>
args@{ self, config, lib, inputs, pkgs, ... }:
let username = "eyesack";
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

    ### COMMUNICATION & MESSAGING ###
    programs.vesktop

    ### MEDIA CREATION ###

    ### MEDIA CONSUMPTION ###
    programs.tidal

    ### OFFICE & WRITING SOFTWARE ###

    ### TERMINAL EMULATORS ###
    programs.alacritty

    ### CODE EDITORS ###
    programs.neovim

    ### DEVELOPMENT TOOLS ###
    programs.nix
    programs.git

    ### SHELL ENVIRONMENTS ###
    programs.zsh

    ### CLI UTILITIES ###
    programs.bat
    programs.lsd
    programs.fzf
    programs.jq

    ### SYSTEM ADMINISTRATION & DIAGNOSTICS ###
    programs.neofetch

    ### VIDEO GAMES ###
    programs.prism-launcher

    ### AUTHENTICATION ###
    programs.keepassxc

    ### FILE SHARING ###

    ### 3D PRINTING ###

    ##############################
    ### USER-SPECIFIC SERVICES ###
    ##############################

    ### MEDIA ###
    services.playerctl

    ### FILE SYNCHRONIZATION ###
    # services.onedrive

    ### DEVICE MANAGEMENT ###
    services.udiskie
    services.easyeffects

    ### SECRET MANAGEMENT ###
    services.keepassxc
  ];
}
