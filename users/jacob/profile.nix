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

    ./fonts.nix

    ### DEFAULT PROGRAMS ###
    # user.mimeApps

    ##############################
    ### USER-SPECIFIC PROGRAMS ###
    ##############################

    ### WEB BROWSERS ###
    programs.firefox
    programs.brave

    ### DOCUMENT/FILETYPE HANDLERS ###
    programs.zathura

    ### COMMUNICATION & MESSAGING ###
    # programs.mailspring
    programs.thunderbird
    # programs.discord.canary
    # programs.discord.webcord
    # programs.armcord
    programs.vesktop
    programs.hexchat
    programs.telegram
    programs.signal
    programs.element
    programs.mattermost

    ### MEDIA CREATION ###
    programs.obs-studio
    programs.handbrake
    programs.ffmpeg
    programs.kdenlive
    programs.shotcut
    programs.pinta
    programs.gimp
    programs.upscayl

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
    programs.rio

    ### CODE EDITORS ###
    (programs.vscode.enable "default")
    (programs.vscode.settings.spikespaz "default")
    (programs.vscode.keybinds.spikespaz "default")
    (programs.vscode.languages.cpp "default")
    (programs.vscode.languages.bash "default")
    (programs.vscode.languages.nix "default")
    (programs.vscode.languages.perl "default")
    (programs.vscode.languages.rust "default")
    (programs.vscode.languages.hare "default")
    (programs.vscode.languages.web "default")
    # (programs.vscode.languages.yuck "default")
    (programs.vscode.languages.python "default")
    (programs.vscode.languages.nushell "default")
    (programs.vscode.languages.javascript "default")
    (programs.vscode.languages.typst "default")
    (programs.vscode.languages.markdown "default")
    (programs.vscode.languages.zig "default")
    # TODO: error: do not use python3Packages when building Python packages, specify each used package as a separate argument
    # (programs.vscode.other.marlin "default")
    (programs.vscode.other.marp "default")
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
    programs.zed

    ### DEVELOPMENT TOOLS ###
    programs.nix
    programs.git
    programs.java
    programs.rust # Does not contain compiler, use devshell.

    ### SHELL ENVIRONMENTS ###
    programs.zsh
    programs.fish
    programs.nushell

    ### CLI UTILITIES ###
    programs.fd
    programs.bat
    programs.lsd
    programs.fzf
    programs.jq
    programs.gallery-dl

    ### SYSTEM ADMINISTRATION & DIAGNOSTICS ###
    programs.remmina
    programs.anydesk
    # TODO: dependency `xtest` is failing to build
    # programs.rustdesk
    programs.neofetch
    programs.nix-index
    programs.virt-manager

    ### VIDEO GAMES ###
    programs.moonlight
    programs.steam
    programs.prism-launcher

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
    # TODO: `python3.12-libarcus-4.12.0` marked as broken
    # programs.cura

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
