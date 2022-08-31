# Consistent theming between Qt and GTK on Wayland with a custom compositor
# is really not an easy feat. This module contains setup to handle that.
{ pkgs, ... }:
  let
    theme = {
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
      kde = {
        package = pkgs.materia-kde-theme;
        name = "MateriaDark";
      };
      font = {
        package = pkgs.ubuntu_font_family;
        name = "Ubuntu";
      };
    };
  in
{
  home.packages = with pkgs; [
    lxqt.lxqt-qtplugin
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum
    theme.kde.package
  ];

  # specify packages to use for gtk theming
  gtk = {
    enable = true;

    cursorTheme.package = theme.cursor.package;
    cursorTheme.name = theme.cursor.name;

    iconTheme.package = theme.icons.package;
    iconTheme.name = theme.icons.name;

    theme.package = theme.gtk.package;
    theme.name = theme.gtk.name;

    font.package = theme.font.package;
    font.name = theme.font.name;
  };

  # libadwaita doesn't respect any precedent
  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = if theme.dark then "prefer-dark" else "prefer-light";
    cursor-size = 24;
  };

  # set the kvantum theme, still needs qt5ct to be manually configured
  # expects pkgs.materia-kde-theme
  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=${theme.kde.name}
  '';

  # use lxqt-qtplugin because qt5ct uses a weird config format
  # the font has more parameters, but this seems to work fine without
  # monospace is currently broken
  xdg.configFile."lxqt/lxqt.conf".text = ''
    [General]
    icon_theme=${theme.icons.name}

    [Qt]
    font="${theme.font.name},9"
    style=kvantum
  '';

  # don't know why the mouse settings are in the session file
  xdg.configFile."lxqt/session.conf".text = ''
    [General]
    cursor_size=${toString theme.cursor.size}
    cursor_theme=${theme.cursor.name}
  '';

  home.sessionVariables = {
    XCURSOR_SIZE = "${toString theme.cursor.size}";
  };
}
