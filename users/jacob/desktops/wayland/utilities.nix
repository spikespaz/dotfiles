{
  config,
  flake,
  lib,
  pkgs,
  ...
}: {
  imports = [
    flake.modules.disable-input.hm-module
  ];

  programs.disable-input-devices = {
    enable = true;
    duration = 45;
    notification = {
      iconCategory = "apps";
      iconName = "computerjanitor";
      title = "Cleaning Mode";
      urgency = "critical";
    };
  };
}
