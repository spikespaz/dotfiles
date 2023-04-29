{ self, config, pkgs, ... }: {
  imports = [
    self.homeManagerModules.randbg
    self.homeManagerModules.uniform-theme
    self.homeManagerModules.kvantum
  ];

  home.sessionVariables.USER_WALLPAPERS_DIRECTORY =
    "${config.home.homeDirectory}/Pictures/Wallpapers";

  # randomly cycle the wallpaper every hour with a 25% chance
  services.randbg = {
    enable = true;
    interval = 60 * 60;
    chance = 25;
    directory = config.home.sessionVariables.USER_WALLPAPERS_DIRECTORY;
  };

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

  programs.kvantum = {
    enable = true;
    qt5ct.enable = true;
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
