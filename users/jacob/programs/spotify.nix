{
  pkgs,
  lib,
  hmModules,
  ...
}: {
  imports = [hmModules.spicetify];

  programs.spicetify = {
    enable = true;
    theme = "catppuccin-mocha";
    colorScheme = "flamingo";

    enabledExtensions = [
      "fullAppDisplay.js"
      "shuffle+.js"
      "hidePodcasts.js"
    ];
  };
}
