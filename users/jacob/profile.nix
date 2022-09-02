# DOCUMENTATION
# <https://nix-community.github.io/home-manager/options.html>
# PACKAGE SEARCH
# <https://search.nixos.org/packages>
{ config, pkgs, nixpkgs, inputs, ... }:
  let
    wallpaper = "/home/jacob/OneDrive/Pictures/Wallpapers/RykyArt Patreon/Favorites/antlers.png";
  in
{
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

  nixpkgs.overlays =
    let
      discordOverlay = self: super: {
        discord = super.discord.override {
          # <https://github.com/GooseMod/OpenAsar>
          withOpenASAR = true;
          # fix for not respecting system browser
          nss = pkgs.nss_latest;
        };
      };
    in
  [
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
    # Wallpaper
    swaybg

    # Session Manager & Lock Screen
    swaylock-effects

    # Screen Capture
    grim
    slurp

    # Device Configuration
    lxqt.pavucontrol-qt  # Pulse Audio Volume Control
    system-config-printer

    # Dolphin File Manager
    libsForQt5.dolphin
    libsForQt5.dolphin-plugins
    libsForQt5.ffmpegthumbs  # Video Thumbnails
    libsForQt5.kimageformats  # Proprieary Image Formats
    resvg  # SVG Thumbnails
    taglib  # Audio File Tags
    # libsForQt5.kio-extras  # ???
    libsForQt5.ark  # Archive GUI

    # KDE Utilities
    libsForQt5.kcolorchooser
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

  # enable automatic-mounting of new drives
  services.udiskie = {
    enable = true;
    tray = "never";
  };

  # configure the wm
  xdg.configFile."hypr/hyprland.conf".source = ./configs/hyprland.conf;
  # write the script for the wallpaper
  # this is an exec in hyprland config
  xdg.configFile."hypr/wallpaper.sh" = {
    text = "swaybg -m fit --image '${wallpaper}'";
    executable= true;
  };
  # screenshot utility
  # this is an exec bind in hyprland config
  xdg.configFile."hypr/prtsc.pl" = {
    source = ./scripts/prtsc.pl;
    executable = true;
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

  programs.swaylock.settings =
    let
      ### Indicator Colors ###

      bg_opacity = "7f";  # 50%
      # fg_opacity = "bf";  # 75%
      fg_opacity = "b2";  # 70%

      inside_color = "0f0f0f";
      text_color = "dedede";
      line_color = "000000";

      ### Ring Colors ###
      # <https://materialui.co/colors/>
      
      ## Normal
      # cyan_500 = "00BCD4";
      teal_500 = "009688";
      ## Normal Keypress
      # cyan_300 = "4DD0E1";
      teal_300 = "4DB6AC";
      ## Normal Backspace
      # cyan_900 = "006064";
      teal_900 = "004D40";
      ## Capslock
      orange_500 = "FF9800";
      ## Capslock Keypress
      orange_300 = "FFB74D";
      ## Capslock Backspace
      orange_900 = "E65100";
      ## Verifying
      # purple_a100 = "EA80FC";
      purple_300 = "BA68C8";
      ## Cleared
      green_a700 = "00C853";
      ## Incorrect
      # red_a700 = "D50000";
      # deep_orange_a400 = "FF3D00";
      deep_orange_600 = "F4511E";
    in
  {
    ### Behavior ###

    ignore-empty-password = true;
    daemonize = true;
    # grace = 5;  # Specify when auto-lock
    grace-no-mouse = true;
    indicator = true;
    show-failed-attempts = true;

    ### Effect ###
    
    fade-in = 200 / 1000;
    screenshots = true;
    effect-blur = "15x3";
    # causes a white border around the edges of the screen
    # effect-scale = 0.5;
    effect-vignette = "0.25:0.5";

    ### Indicator ###
    
    clock = true;
    timestr = "%-I:%M:%S %p";
    datestr = "%a, %b %-d, %Y";
    indicator-idle-visible = true;
    indicator-caps-lock = true;
    indicator-radius = 80;
    indicator-thickness = 6;

    ### Text ###
    
    font = "Ubuntu";
    font-size = 22;
    text-color = text_color;
    text-clear-color = text_color;
    text-caps-lock-color = text_color;
    text-ver-color = text_color;
    text-wrong-color = text_color;

    ### Background ###
    
    inside-color = inside_color + bg_opacity;
    inside-clear-color = inside_color + bg_opacity;
    inside-caps-lock-color = inside_color + bg_opacity;
    inside-ver-color = inside_color + bg_opacity;
    inside-wrong-color = inside_color + bg_opacity;

    ### Line ###

    separator-color = line_color;
    line-color = line_color;
    line-clear-color = line_color;
    line-caps-lock-color = line_color;
    line-ver-color = line_color;
    line-wrong-color = line_color;

    ### Ring ###

    ring-color = teal_500 + fg_opacity;
    key-hl-color = teal_300 + fg_opacity;
    bs-hl-color = teal_900 + fg_opacity;

    ring-caps-lock-color = orange_500 + fg_opacity;
    caps-lock-key-hl-color = orange_300 + fg_opacity;
    caps-lock-bs-hl-color = orange_900 + fg_opacity;

    ring-ver-color = purple_300 + fg_opacity;
    ring-clear-color = green_a700 + fg_opacity;
    ring-wrong-color = deep_orange_600 + fg_opacity;
  };

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

# ========
# This function is for prepending the Hyprland config with environment variables.
# No shell session seemed to respect these.
# ========
#
# let
#   mkHyprEnvVars = { vars, index ? 0, head ? "" }:
#     if index < builtins.length (builtins.attrNames vars) then
#       mkHyprEnvVars {
#         inherit vars;
#         index = index + 1;
#         head = head + "exec-once=export ${builtins.elemAt (builtins.attrNames vars) index}='${builtins.toString (builtins.elemAt (builtins.attrValues vars) index)}'\n";
#       }
#     else
#       head + "\n";
# in
#
# --------
#
# xdg.configFile."hypr/hyprland.conf".text =
#   (mkHyprEnvVars { vars = config.home.sessionVariables; })
#   + (builtins.readFile ./configs/hyprland.conf);
#
# ========
# This should have made all variables accessible to programs whom do not respect `~/.profile`.
# It appears to change nothing.
# ========
#
# home.sessionVariables = {
#   QT_QPA_PLATFORM = "wayland";
#   #XDG_CURRENT_DESKTOP = "sway"
#   #XDG_SESSION_DESKTOP = "sway"
#   #XDG_CURRENT_SESSION_TYPE = "wayland"
#   QT_QPA_PLATFORMTHEME = "qt5ct";
#   QT_STYLE_OVERRIDE = "kvantum";
#   GTK_USE_PORTAL = 1;
#   MOZ_ENABLE_WAYLAND = 1;
#   _JAVA_AWT_WM_NONREPARENTING = 1;
#   XCURSOR_SIZE = 24;
# };
#
# --------
#
# pam.sessionVariables = config.home.sessionVariables;
#
# ========
