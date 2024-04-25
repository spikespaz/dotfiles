{ lib, pkgs, config, ... }:
let
  wavefox = pkgs.stdenv.mkDerivation (self: {
    pname = "wavefox-userchrome";
    version = "1.6.123";
    src = pkgs.fetchFromGitHub {
      owner = "QNetITQ";
      repo = "WaveFox";
      rev = "v${self.version}";
      hash = "sha256-uVGNJKtT8MHo5a+GTW6DfpuRiCukC4e4UdnKmWIk3Zw=";
    };
    installPhase = ''
      mkdir $out
      cp -r $src/chrome -T $out
      cp -r $src/{README.md,LICENSE} -t $out
    '';
  });
in {
  programs.firefox.profiles."jacob.default" = {
    settings = {
      # Enable new WebRender everywhere.
      "gfx.webrender.all" = true;

      # Hide the crap on the New Tab page.
      "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
      "browser.newtabpage.activity-stream.feeds.topsites" = false;
    };
  };

  # <https://github.com/QNetITQ/WaveFox>
  programs.firefox.userChrome.profiles."jacob.default" = lib.mkForce {
    # recursive = true;
    source = wavefox;

    extraSettings = {
      "browser.uidensity" = 1;
      # "ui.prefersReducedMotion" = 1;
      "browser.tabs.tabMinWidth" = 130;

      # Fix for the close button being inline wth tabs.
      "browser.tabs.inTitlebar" = 0;

      # WaveFox
      "svg.context-properties.content.enabled" = true;

      # slight rounding
      "userChrome.Tabs.Option8.Enabled" = true;

      # "browser.tabs.inTitlebar" = 1; # needed for transparency
      # "userChrome.Linux.Transparency.Low.Enabled" = true;
      "userChrome.DarkTheme.Tabs.Shadows.Saturation.Low.Enabled" = true;
      "userChrome.TabSeparators.Saturation.Medium.Enabled" = true;
      # "userChrome.Menu.Size.Compact.Enabled" = true;
    };
  };
}
