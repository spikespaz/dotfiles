# DOCUMENTATION
# <https://nix-community.github.io/home-manager/options.html>
# PACKAGE SEARCH
# <https://search.nixos.org/packages>
args @ { config, lib, ulib, pkgs, nixpkgs, hmModules, ... }: let
  programs = import ./programs args;
  services = import ./services.nix args;
  mimeApps = ulib.importMimeApps ./mimeapps.nix;
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

  home.username = "jacob";
  home.homeDirectory = "/home/${config.home.username}";

  xdg.enable = true;
  xdg.userDirs.enable = true;
  xdg.userDirs.createDirectories = true;

  home.sessionVariables = {
    # gtk applications should use filepickers specified by xdg
    GTK_USE_PORTAL = "1";
  };

  programs.home-manager.enable = true;

  # should already be enabled at system level
  # fontconfig required to make user-fonts by name
  # todo: figure out how to make ~/.local/share/fonts
  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    BROWSER = "firefox";
    TERMINAL = "alacritty";
    EDITOR = "nvim";
  };

  programs.alacritty.settings.shell = {
    program = "${lib.getExe pkgs.zsh}";
    args = [ "--login" ];
  };

  ##########################
  ### PACKAGES & MODULES ###
  ##########################

  imports = [
    ### THEMING MODULES ###
    hmModules.uniform-theme
    hmModules.kvantum

    ### DEFAULT PROGRAMS ###
    mimeApps

    ##############################
    ### USER-SPECIFIC SOFTWARE ###
    ##############################

    ### WEB BROWSERS ###
    programs.firefox
    programs.chromium

    ### COMMUNICATION & MESSAGING ###
    programs.mailspring
    # programs.discord
    programs.webcord
    programs.hexchat

    ### MEDIA CREATION ###
    programs.obs-studio

    ### MEDIA CONSUMPTION ###
    programs.spotify

    ### OFFICE & WRITING SOFTWARE ###
    programs.onlyoffice
    programs.apostrophe

    ### TERMINAL EMULATORS ###
    programs.alacritty

    ### CODE EDITORS ###
    programs.vscode.settings
    programs.vscode.languages.all
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

    ##############################
    ### USER-SPECIFIC SERVICES ###
    ##############################

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
