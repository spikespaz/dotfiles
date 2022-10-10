{
  self,
  config,
  pkgs,
  lib,
  hmModules,
  ...
}: {
  homeage.file."jacob.spotifyd.age" = {
    source = "${self}/secrets/jacob.spotifyd.age";
  };

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
        username = "spikespaz@outlook.com";
        password_cmd = "cat '${config.homeage.mount}/jacob.spotifyd.age'";
      };
    };
  };

  # files.configHome."spotifyd".text = tomlFormat config.services.spotifyd.setting;

  home.packages = with pkgs; [
    spotify-tui
    spotify-qt
  ];
}
