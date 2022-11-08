{
  pkgs,
  hmModules,
  ...
}: {
  imports = [hmModules.webcord];

  programs.webcord = {
    enable = true;
    themes = let
      bdAddons = pkgs.fetchFromGitHub {
        owner = "mwittrien";
        repo = "BetterDiscordAddons";
        rev = "8627bb7f71c296d9e05d82538d3af8f739f131dc";
        sha256 = "sha256-Dn6igqL0GvaOcTFZOtQOxuk0ikrWxyDZ41tNsJXJAxc=";
      };
    in {
      DiscordRecolor = "${bdAddons}/Themes/DiscordRecolor/DiscordRecolor.theme.css";
      SettingsModal = "${bdAddons}/Themes/SettingsModal/SettingsModal.theme.css";
    };
  };
}
