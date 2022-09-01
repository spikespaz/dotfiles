# Consistent theming between Qt and GTK on Wayland with a custom compositor
# is really not an easy feat. This module contains setup to handle that.
{ pkgs, ... }:
  let
    theme = with pkgs; {
      dark = true;
      cursor = {
        package = quintom-cursor-theme;
        name = "Quintom_Ink";
        size = 24;
      };
      icons = {
        package = papirus-icon-theme;
        name = "Papirus-Dark";
      };
      gtk = {
        package = materia-theme;
        name = "Materia-dark-compact";
      };
      kde = {
        package = materia-kde-theme;
        # name = "MateriaDark";
      };
      fonts = {
        default = {
          package = ubuntu_font_family;
          name = "Ubuntu";
        };
        monospace = {
          package = dejavu_fonts;
          name = "DejaVu Sans Mono";
        };
      };
    };
  in
{
  # specify packages that are required for some stuff below
  home.packages = [
    # lxqt.lxqt-qtplugin
    pkgs.libsForQt5.qt5ct
    pkgs.libsForQt5.qtstyleplugin-kvantum
    theme.kde.package
    theme.fonts.monospace.package
  ];

  # use qt5ct in tandem with kvantum
  home.sessionVariables.QT_QPA_PLATFORMTHEME = "qt5ct";

  # specify packages to use for gtk theming
  gtk = {
    enable = true;

    iconTheme.package = theme.icons.package;
    iconTheme.name = theme.icons.name;

    theme.package = theme.gtk.package;
    theme.name = theme.gtk.name;

    font.package = theme.fonts.default.package;
    font.name = theme.fonts.default.name;
  };

  # libadwaita doesn't respect any precedent
  dconf.settings."org/gnome/desktop/interface" = {
    monospace-font-name = theme.fonts.monospace.name;
    color-scheme = if theme.dark then "prefer-dark" else "prefer-light";
    # don't know if this is needed
    # cursor-size = 24;
  };

  home.pointerCursor = {
    package = theme.cursor.package;
    name = theme.cursor.name;
    size = theme.cursor.size;
    gtk.enable = true;
    x11.enable = true;
  };

  # should cover any other bases
  home.sessionVariables.XCURSOR_SIZE = "${toString theme.cursor.size}";

  # set the kvantum theme, still needs qt5ct to be manually configured
  # expects pkgs.materia-kde-theme
  # xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
  #   [General]
  #   theme=${theme.kde.name}
  # '';

  # # use lxqt-qtplugin because qt5ct uses a weird config format
  # # the font has more parameters, but this seems to work fine without
  # # monospace is currently broken
  # xdg.configFile."lxqt/lxqt.conf".text = ''
  #   [General]
  #   icon_theme=${theme.icons.name}

  #   [Qt]
  #   font="${theme.fonts.default.name},9"
  #   style=kvantum
  # '';

  # # don't know why the mouse settings are in the session file
  # xdg.configFile."lxqt/session.conf".text = ''
  #   [General]
  #   cursor_size=${toString theme.cursor.size}
  #   cursor_theme=${theme.cursor.name}
  # '';

  # qt5ct does the job better, just have to figure out exactly
  # how the fonts work
  # they are dumped from a QFont object
  # <https://doc.qt.io/qt-5/qfont.html>
  # xdg.configFile."qt5ct/qt5ct.conf".text = ''
  #   [Appearance]
  #   color_scheme_path=${pkgs.libsForQt5.qt5ct}/share/qt5ct/colors/${if theme.dark then "darker" else "airy"}.conf
  #   custom_palette=true
  #   icon_theme=${theme.icons.name}
  #   standard_dialogs=default
  #   style=kvantum

  #   [Fonts]
  #   fixed=@Variant(\0\0\0@\0\0\0 \0\x44\0\x65\0j\0\x61\0V\0u\0 \0S\0\x61\0n\0s\0 \0M\0o\0n\0o@\"\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x91)
  #   general=@Variant(\0\0\0@\0\0\0\f\0U\0\x62\0u\0n\0t\0u@\"\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)

  #   [Interface]
  #   activate_item_on_single_click=1
  #   buttonbox_layout=0
  #   cursor_flash_time=1000
  #   dialog_buttons_have_icons=1
  #   double_click_interval=400
  #   gui_effects=@Invalid()
  #   keyboard_scheme=2
  #   menus_have_icons=true
  #   show_shortcuts_in_context_menus=true
  #   stylesheets=@Invalid()
  #   toolbutton_style=4
  #   underline_shortcut=1
  #   wheel_scroll_lines=3
  # '';
}
