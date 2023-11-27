{ self, config, lib, pkgs, ... }: {
  imports = [
    self.homeManagerModules.osd-functions
    self.homeManagerModules.disable-input
  ];

  utilities.osd-functions.settings = {
    notification = {
      duration = 700;
      urgency = "critical"; # show at the top
      colors.highlightNormal = "#458588e6";
      colors.highlightWarning = "#cc241de6";
    };
    audioOutput = {
      maxVolume = 1.25;
      notification.title = "Audio Output";
    };
    audioInput = { notification.title = "Audio Input"; };
  };

  programs.disable-input-devices = {
    enable = true;
    delay = 750;
    duration = 45;
    notification = {
      iconCategory = "apps";
      iconName = "computerjanitor";
      title = "Cleaning Mode";
      urgency = "critical";
    };
  };
}
