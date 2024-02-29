{ lib, pkgs, config, ... }:
let
  wavefox = let
    wavefoxMajorMinor = "1.6";
    version = "${wavefoxMajorMinor}.${firefoxMajor}";
    hashes = {
      "1.6.121" = "sha256-YV6d/yYC42EmN8fVMvC95GSNqUWrCuS5tdHpv+1+C1U=";
      "1.6.122" = "sha256-29LleIJ+c9HYyxlE59pP09OMzPKcx2JDeidZcBOs6+0=";
      "1.6.123" = "sha256-uVGNJKtT8MHo5a+GTW6DfpuRiCukC4e4UdnKmWIk3Zw=";
    };

    firefoxVer = config.programs.firefox.package.version;
    firefoxMajor = (lib.lsplitString "." firefoxVer).l;
  in pkgs.stdenv.mkDerivation (self: {
    pname = "wavefox-userchrome";
    inherit version;
    src = pkgs.fetchFromGitHub {
      owner = "QNetITQ";
      repo = "WaveFox";
      rev = "v${self.version}";
      hash = hashes.${self.version};
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
