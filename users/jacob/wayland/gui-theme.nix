{ self, config, pkgs, pkgs-stable, ... }: {
  imports = [
    #
    self.homeManagerModules.randbg
    self.homeManagerModules.kvantum
  ];

  ## WALLPAPER ##

  home.sessionVariables.USER_WALLPAPERS_DIRECTORY =
    "${config.home.homeDirectory}/OneDrive/Pictures/Wallpapers";

  # randomly cycle the wallpaper every hour with a 25% chance
  services.randbg = {
    enable = true;
    interval = 60 * 60;
    chance = 25;
    directory = config.home.sessionVariables.USER_WALLPAPERS_DIRECTORY;
    swaybg.mode = "fill";
  };

  ## CURSOR, ICONS, GTK THEME, DEFAULT FONTS ##

  gtk = {
    enable = true;
    iconTheme.package = pkgs.papirus-icon-theme;
    iconTheme.name = "Papirus-Dark";
    # FIXME Should be investigated but...
    # As of 2023-11-19, an update to nixpkgs in the last few days
    # has caused this package to stop building,
    # ```
    # cp: cannot stat '/build/source/build/src/cinnamon/Materia.cinnamon.css': No such file or directory
    # ```
    # So, we use `pkgs-stable`.
    theme.package = pkgs-stable.materia-theme;
    theme.name = "Materia-dark-compact";
    font.package = pkgs.ubuntu_font_family;
    font.name = "Ubuntu";
  };

  home.packages = [ pkgs.dejavu_fonts ];

  dconf.settings."org/gnome/desktop/interface" = {
    monospace-font-name = "DejaVu Sans Mono";
    color-scheme = "prefer-dark";
    # cursor-size = 24;
  };

  home.pointerCursor = {
    package = pkgs.quintom-cursor-theme;
    name = "Quintom_Ink";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  home.sessionVariables.XCURSOR_SIZE = toString 24;

  ## KDE THEME ##

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
