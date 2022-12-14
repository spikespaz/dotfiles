# DOCUMENTATION
# <https://nix-community.github.io/home-manager/options.html>
# PACKAGE SEARCH
# <https://search.nixos.org/packages>
{
  flake,
  config,
  lib,
  ulib,
  pkgs,
  nixpkgs,
  hmModules,
  ...
}: let
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
  homeage.identityPaths = [
    "~/.ssh/id_ed25519"
  ];
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
    inherit (user) services programs;
  in [
    ###############################
    ### MODULES & MISCELLANEOUS ###
    ###############################

    hmModules.homeage

    ### THEMING MODULES ###
    hmModules.uniform-theme
    hmModules.kvantum

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
    programs.spotify

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
    # TODO broken idk why
    # programs.vscode.languages.all
    programs.neovim
    programs.helix
    programs.lapce

    ### DEVELOPMENT TOOLS ###
    programs.git

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
    programs.transmission
    programs.filezilla

    ##############################
    ### USER-SPECIFIC SERVICES ###
    ##############################

    ### MEDIA ###
    services.spotify

    ### FILE SYNCHRONIZATION ###
    services.onedrive

    ### DEVICE MANAGEMENT ###
    services.udiskie
  ];

  ############################
  ### APPEARANCE & THEMING ###
  ############################

  home.uniformTheme = {
    enable = true;
    dark = true;
    cursor = {
      package = pkgs.quintom-cursor-theme;
      name = "Quintom_Ink";
      size = 24;
    };
    icons = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    gtk = {
      package = pkgs.materia-theme;
      name = "Materia-dark-compact";
    };
    fonts = {
      default = {
        package = pkgs.ubuntu_font_family;
        name = "Ubuntu";
      };
      monospace = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans Mono";
      };
    };
  };

  programs.kvantum = {
    enable = true;
    qt5ct.enable = true;
    theme.package = pkgs.materia-kde-theme;
    theme.name = "MateriaDark";
    theme.overrides = {
      General = {
        no_inactiveness = true;
        translucent_windows = true;
        reduce_window_opacity = 13;
        reduce_menu_opacity = 13;
        drag_from_buttons = false;
        shadowless_popup = true;
        popup_blurring = true;
        menu_blur_radius = 5;
        tooltip_blur_radius = 5;
      };
      Hacks = {
        transparent_dolphin_view = true;
        style_vertical_toolbars = true;
      };
    };
  };
}
