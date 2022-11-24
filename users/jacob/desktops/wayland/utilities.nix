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
    duration = 60;
    notification = {
      # countdown = duration - 2;
      iconName = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/24x24/apps/computerjanitor.svg";
      title = "Cleaning Mode";
    };
  };
}
