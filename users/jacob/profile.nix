# DOCUMENTATION
# <https://nix-community.github.io/home-manager/options.html>
# PACKAGE SEARCH
# <https://search.nixos.org/packages>
args @ { config, lib, pkgs, nixpkgs, dotpkgs, ... }: let
  programs = import ./programs args;
  services = import ./services.nix args;
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

  imports = [
    # theming module
    dotpkgs.hmModules.uniform-theme
    # set the default programs
    ./mimeapps.nix

    ##############################
    ### USER-SPECIFIC SOFTWARE ###
    ##############################

    ### WEB BROWSERS ###
    programs.firefox
    programs.chromium

    ### COMMUNICATION & MESSAGING ###
    programs.mailspring
    programs.discord
    programs.webcord
    programs.neochat
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
    programs.vscode
    programs.neovim
    programs.helix

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
    # services.udiskie
  ];

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
    kvantum = {
      package = pkgs.materia-kde-theme;
      name = "MateriaDark";
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
}
