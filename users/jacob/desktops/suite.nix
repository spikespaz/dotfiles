# desktop environment default programs
{pkgs, ...}: {
  home.packages = with pkgs; [
    # Utilities
    wl-clipboard
    xdg-utils

    # Diagnostics
    wev
    qdirstat

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
    libsForQt5.ark # Archive GUI

    # KDE Utilities
    libsForQt5.kcolorchooser # Color Chooser
    libsForQt5.kate # Text Editor
    libsForQt5.kdf # Disk Usage
    libsForQt5.kompare # Difference Viewer
    libsForQt5.okular # Document Viewer
    libsForQt5.print-manager # Print Manager
    libsForQt5.skanlite # Lightweight Document Scanner

    # Video Player
    haruna

    # LXQT Utilities
    lxqt.lximage-qt # Image Viewer

    # Generic Utilities
    qalculate-gtk
    font-manager
  ];
}
