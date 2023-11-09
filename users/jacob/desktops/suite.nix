# desktop environment default programs
{ lib, pkgs, ... }: {
  home.packages = with pkgs; [
    # CLI Utilities
    wl-clipboard
    xdg-utils

    # Diagnostics & System Tools
    cpu-x
    wev
    qdirstat
    gparted

    # Device Configuration
    lxqt.pavucontrol-qt # Pulse Audio Volume Control
    system-config-printer
    iwgtk # Wireless GUI

    # Authentication
    # libsForQt5.kauth
    # libsForQt514.polkit-kde-agent
    # lxqt.lxqt-policykit
    # polkit_gnome
    # pantheon.pantheon-agent-polkit
    # libsForQt5.kwallet
    gnome.seahorse
    libsecret

    # Dolphin File Manager
    libsForQt5.dolphin
    libsForQt5.dolphin-plugins
    libsForQt5.kio-extras
    libsForQt5.ffmpegthumbs # Video Thumbnails
    libsForQt5.kimageformats # Proprieary Image Formats
    resvg # SVG Thumbnails
    taglib # Audio File Tags
    libsForQt5.kfind # File Search
    libsForQt5.ark # Archive GUI

    # KDE Utilities
    libsForQt5.kcolorchooser # Color Chooser
    libsForQt5.kate # Text Editor
    libsForQt5.kdf # Disk Usage
    libsForQt5.kompare # Difference Viewer
    libsForQt5.okular # Document Viewer
    libsForQt5.print-manager # Print Manager
    libsForQt5.skanlite # Lightweight Document Scanner

    # General Utilities
    gnome.gnome-sound-recorder

    # Video Player
    haruna

    # LXQT Utilities
    lxqt.lximage-qt # Image Viewer

    # Generic Utilities
    qalculate-gtk
    font-manager

    # Compatibility
    appimage-run
  ];

  xdg.configFile."dolphinrc".text = ''
    MenuBar=Disabled

    [DetailsMode]
    PreviewSize=22

    [General]
    ShowStatusBar=false
    UseTabForSwitchingSplitView=true
    Version=202

    [IconsMode]
    PreviewSize=160

    [KFileDialog Settings]
    Places Icons Auto-resize=false
    Places Icons Static Size=22
    detailViewIconSize=16

    [MainWindow]
    MenuBar=Disabled
    ToolBarsMovable=Disabled

    [MainWindow][Toolbar mainToolBar]
    ToolButtonStyle=IconOnly

    [Toolbar mainToolBar]
    ToolButtonStyle=IconOnly
  '';
}
