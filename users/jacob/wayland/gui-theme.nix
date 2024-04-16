{ self, config, pkgs, pkgs-stable, ... }: {
  imports = [
    #
    self.homeManagerModules.randbg
    self.homeManagerModules.kvantum
    ./kde-theme.nix
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
    theme.package = pkgs.materia-theme;
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
}
