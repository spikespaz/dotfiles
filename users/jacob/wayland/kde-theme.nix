{ pkgs, lib, config, ... }:
let inherit (pkgs) materia-kde-theme;
in {
  qt.enable = true;
  qt.platformTheme.name = "qtct";
  qt.style.name = "kvantum";

  programs.kvantum = {
    enable = true;
    theme.package = materia-kde-theme;
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

  xdg.configFile."qt6ct/qt6ct.conf".text = lib.generators.toINI { } {
    Appearance = {
      color_scheme_path =
        "${materia-kde-theme}/share/color-schemes/MateriaDark.colors";
      custom_palette = true;
      icon_theme = config.gtk.iconTheme.name;
      standard_dialogs = "xdgdesktopportal";
      style = "kvantum";
    };

    Fonts = {
      fixed = "JetBrainsMono Nerd Font,12,-1,5,50,0,0,0,0,0,Regular";
      general = "Ubuntu,12,-1,5,50,0,0,0,0,0,Regular";
    };

    Interface = let
      KEYBOARD_SCHEME_KDE = 3;
      FOLLOW_APPLICATION_STYLE = 4;
    in {
      activate_item_on_single_click = 1;
      buttonbox_layout = 0;
      cursor_flash_time = 1000;
      dialog_buttons_have_icons = 1;
      double_click_interval = 400;
      gui_effects = "@Invalid()";
      keyboard_scheme = KEYBOARD_SCHEME_KDE;
      menus_have_icons = true;
      show_shortcuts_in_context_menus = true;
      stylesheets = "@Invalid()";
      toolbutton_style = FOLLOW_APPLICATION_STYLE;
      underline_shortcut = 1;
      wheel_scroll_lines = 3;
    };
  };
  xdg.configFile."qt5ct/qt5ct.conf".text =
    config.xdg.configFile."qt6ct/qt6ct.conf".text;
}
