# desktop environment default programs
{ lib, pkgs, ... }: {
  home.packages = with pkgs;
    lib.flatten [
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

      (with pkgs.libsForQt5; [
        # File Management
        dolphin
        dolphin-plugins
        kio-extras
        ffmpegthumbs # Video Thumbnails
        kimageformats # Proprieary Image Formats
        kfind # File Search
        ark # Archive GUI

        # KDE Utilities
        kcolorchooser # Color Chooser
        kate # Text Editor
        kdf # Disk Usage
        kompare # Difference Viewer
        okular # Document Viewer
        print-manager # Print Manager
        skanlite # Lightweight Document Scanner
      ])

      resvg # SVG Thumbnails
      taglib # Audio File Tags

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
