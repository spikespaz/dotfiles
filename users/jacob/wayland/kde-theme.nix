{ pkgs, lib, ... }: {
  qt.enable = true;
  qt.platformTheme = "qtct";
  # qt.style.name = "kvantum";
  home.packages = [ pkgs.libsForQt5.qt5ct ];

  # The HM module seems to be broken when it sets this.
  # Variables are `at5ct` for backwards-compatibility.
  # home.sessionVariables.QT_STYLE_OVERRIDE = lib.mkForce "kvantum";
  # systemd.user.sessionVariables.QT_STYLE_OVERRIDE = lib.mkForce "kvantum";
  # home.sessionVariables.QT_QPA_PLATFORMTHEME = lib.mkForce "qt5ct";
  # systemd.user.sessionVariables.QT_QPA_PLATFORMTHEME = lib.mkForce "qt5ct";

  programs.kvantum = {
    enable = true;
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
