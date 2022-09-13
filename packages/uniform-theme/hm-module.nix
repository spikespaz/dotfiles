args @ { config, lib, pkgs, ... }: let
  description = ''
    Consistent theming between Qt and GTK on Wayland with a custom compositor
    is really not an easy feat. This module contains setup to handle that.
  '';
  cfg = config.home.uniformTheme;
in {
  options = {
    home.uniformTheme = {
      enable = lib.mkEnableOption description;
    } // (
      import ./options.nix args
    );
  };
  config = lib.mkIf cfg.enable (import ./config.nix cfg args);
}
