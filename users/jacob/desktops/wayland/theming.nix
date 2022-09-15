{ config, dotpkgs, ... }: {
  imports = [
    dotpkgs.homeManagerModules.randbg
  ];

  # configure swaylock theme
  programs.swaylock.settings = import ./swaylock.nix;

  # randomly cycle the wallpaper every hour with a 25% chance
  services.randbg = {
    enable = true;
    interval = 60 * 60;
    chance = 25;
    directory = "${config.home.homeDirectory}/Pictures/Wallpapers";
  };
}
