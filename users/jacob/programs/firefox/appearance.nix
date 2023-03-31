{
  lib,
  pkgs,
  ...
}: let
  profile = "jacob.default";

  styles = pkgs.fetchFromGitHub {
    owner = "Aris-t2";
    repo = "CustomCSSforFx";
    rev = "4.3.3";
    sha256 = "sha256-57Hoc0103gy9lO0XGveoWXNVxhbmDr0CteHXaaP2po4=";
  };
in {
  home.file.".mozilla/firefox/${profile}/chrome".source = "${styles}/current";
  programs.firefox.profiles.${profile}.userChrome = builtins.readFile ./userChrome.css;
}
