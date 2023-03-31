{
  lib,
  pkgs,
  ...
}: let
  profile = "jacob.default";

  styles =
    lib.traceVal
    (pkgs.symlinkJoin {
      name = "firefox-css-styles";
      paths = [
        # First our replacement files
        ./.
        # Then the git source
        ((pkgs.fetchFromGitHub {
            owner = "Aris-t2";
            repo = "CustomCSSforFx";
            rev = "4.3.3";
            sha256 = "sha256-57Hoc0103gy9lO0XGveoWXNVxhbmDr0CteHXaaP2po4=";
          })
          .outPath
          + "/current")
      ];
    })
    .outPath;
in {
  home.file.".mozilla/firefox/${profile}/chrome".source = styles;
  # programs.firefox.profiles.${profile} = {
  #   userChrome = builtins.readFile ./userChrome.css;
  #   userContent = builtins.readFile ./userContent.css;
  # };
}
