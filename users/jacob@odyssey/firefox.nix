{ lib, pkgs, config, ... }:
let
  wavefox = let
    wavefoxMajorMinor = "1.6";
    version = "${wavefoxMajorMinor}.${firefoxMajor}";
    hash = "sha256-YV6d/yYC42EmN8fVMvC95GSNqUWrCuS5tdHpv+1+C1U=";

    firefoxVer = config.programs.firefox.package.version;
    firefoxMajor = (lib.lsplitString "." firefoxVer).l;
  in pkgs.stdenv.mkDerivation (self: {
    pname = "wavefox-userchrome";
    inherit version;
    src = pkgs.fetchFromGitHub {
      owner = "QNetITQ";
      repo = "WaveFox";
      rev = "v${self.version}";
      inherit hash;
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
      # enable new webrender everywhere
      "gfx.webrender.all" = true;
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
