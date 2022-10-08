{
  config,
  pkgs,
  lib,
  ...
}: let
  # tomlFormat = pkgs.formats.toml { };
in {
  services.spotifyd = {
    enable = true;
    package = pkgs.spotifyd.override {
      withKeyring = true;
      withMpris = true;
      withPulseAudio = true;
    };
    settings = {
      global = {
        backend = "pulseaudio";
        bitrate = 320;
        use_mpris = true;
      };
    };
  };

  # files.configHome."spotifyd".text = tomlFormat config.services.spotifyd.setting;

  home.packages = with pkgs; [
    spotify-tui
    spotify-qt
  ];
}
