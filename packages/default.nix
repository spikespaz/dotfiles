pkgs: let
  maintainers = {
    spikespaz = {
      email = "jacob@birkett.dev";
      github = "spikespaz";
      githubId = "MDQ6VXNlcjEyNTAyOTg4";
      name = 12502988;
    };
  };
in {
  ja-netfilter = pkgs.callPackage ./ja-netfilter {};
  prtsc = pkgs.callPackage ./prtsc {
    inherit maintainers;
  };
  ttf-ms-win11 = pkgs.callPackage ./ttf-ms-win11 {};
  fastfetch = pkgs.callPackage ./fastfetch.nix {};
  firefox-pwa = pkgs.callPackage ./firefox-pwa.nix {
    inherit maintainers;
  };
  idlehack = pkgs.callPackage ./idlehack.nix {
    inherit maintainers;
  };
  plymouth-themes = pkgs.callPackage ./plymouth-themes.nix {};
  rofi-themes = pkgs.callPackage ./rofi-themes.nix {};
}
