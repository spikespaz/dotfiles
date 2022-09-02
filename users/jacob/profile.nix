# DOCUMENTATION
# <https://nix-community.github.io/home-manager/options.html>
# PACKAGE SEARCH
# <https://search.nixos.org/packages>
{ config, pkgs, nixpkgs, inputs, ... }: {
  ################
  ### PREAMBLE ###
  ################

  imports = [ ../user_lib.nix ];

  # <https://github.com/nix-community/home-manager/issues/2942>
  # nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true;

  # fix for some display managers not using ~/.profile
  systemd.user.sessionVariables = config.home.sessionVariables;

  home.stateVersion = "22.05";

  ###################
  ### BASIC SETUP ###
  ###################

  home.username = "jacob";
  home.homeDirectory = "/home/${config.home.username}";

  xdg.enable = true;
  xdg.userDirs.enable = true;
  xdg.userDirs.createDirectories = true;

  home.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    GTK_USE_PORTAL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };

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
    mailspring
    discord
    neochat
  ];

  nixpkgs.overlays = let
    discordOverlay = self: super: {
      discord = super.discord.override {
        # <https://github.com/GooseMod/OpenAsar>
        withOpenASAR = true;
        # fix for not respecting system browser
        nss = pkgs.nss_latest;
      };
    };
  in [
    discordOverlay
  ];

  programs.hexchat.enable = true;

  # Office Software

  userPackages.office = with pkgs; [
    qalculate-gtk
    onedrive
    # OnlyOffice needs to be run once with:
    # `DesktopEditors --force-scale=1 --system-title-bar`
    onlyoffice-bin
    apostrophe  # Replace this
  ];

  # Content Sharing

  programs.obs-studio.enable = true;

  ###########################
  ### DESKTOP ENVIRONMENT ###
  ###########################

  userPackages.desktop = with pkgs; [
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
    font-manager

  ];

  # application launcher
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
  };

  # should already be enabled at system level
  # fontconfig required to make user-fonts by name
  # todo: figure out how to make ~/.local/share/fonts
  fonts.fontconfig.enable = true;

  userPackages.fonts = with pkgs; [
    # google-fonts
    (nerdfonts.override {
      fonts = [
        "Iosevka"
        "FiraCode"
        "JetBrainsMono"
        "FantasqueSansMono"
      ];
    })
  ];

  ####################
  ### WEB BROWSERS ###
  ####################
  
  programs.firefox.enable = true;

  programs.chromium.enable = true;

  #########################
  ### DEVELOPMENT TOOLS ###
  #########################

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

  programs.helix.enable = true;

  programs.neovim.enable = true;

  #########################
  ### GENERIC CLI TOOLS ###
  #########################

  userPackages.cli = with pkgs; [
    blesh  # Bash Line Editor
    wl-clipboard
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
