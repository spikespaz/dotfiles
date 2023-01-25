{
  config,
  hmModules,
  ...
}: {
  imports = [hmModules.randbg];

  # randomly cycle the wallpaper every hour with a 25% chance
  services.randbg = {
    enable = true;
    interval = 60 * 60;
    chance = 25;
    directory = "${config.home.homeDirectory}/Pictures/Wallpapers";
  };
}
