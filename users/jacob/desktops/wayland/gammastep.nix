{ hmModules, ... }: {
  imports = [ hmModules.gammastep-hook ];

  services.gammastep = {
    enable = true;
    tray = true;
    dawnTime = "6:30-8:00"; # 6:30 AM to 8:00 AM
    # duskTime = "20:30-22:00"; # 8:30 PM to 10:00 PM
    duskTime = "18:30-21:00"; # 6:30 PM to 9:00 PM
    provider = "geoclue2";
    temperature.day = 6500;
    temperature.night = 3700;
    settings.general = {
      fade = true;
      adjustment-method = "wayland";
    };

    slight.brightnessHook = {
      enable = true;
      brightness.day = 90;
      brightness.transition = 60;
      brightness.night = 30;
      interpDur.dayFromTransition = "10s";
      interpDur.nightFromTransition = "10s";
      interpDur.transitionFromDay = "20s";
      interpDur.transitionFromNight = "30s";
    };
  };
}
