{ self, config, pkgs, lib, hmModules, ... }: {
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
        password_cmd =
          "${pkgs.coreutils}/bin/cat '${config.homeage.mount}/jacob.spotifyd.age'";
      };
    };
  };

  home.packages = with pkgs; [
    config.services.spotifyd.package
    # spotify-tui
    spotify-qt
  ];

  xdg.configFile."spotifyd/spotifyd.conf".source =
    ((pkgs.formats.toml { }).generate "spotifyd.conf"
      config.services.spotifyd.settings);
}
