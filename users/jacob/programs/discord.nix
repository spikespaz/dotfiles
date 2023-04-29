{ pkgs, ... }:
let
  bdAddons = pkgs.fetchFromGitHub {
    owner = "mwittrien";
    repo = "BetterDiscordAddons";
    rev = "8627bb7f71c296d9e05d82538d3af8f739f131dc";
    sha256 = "sha256-Dn6igqL0GvaOcTFZOtQOxuk0ikrWxyDZ41tNsJXJAxc=";
  };
  discordPackage = (pkgs.discord-canary.override {
    # <https://github.com/GooseMod/OpenAsar>
    withOpenASAR = true;
    # fix for not respecting system browser
    nss = pkgs.nss_latest;
  }).overrideAttrs (old:
    let binaryName = "DiscordCanary";
    in {
      # why is this missing?
      # <https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/instant-messengers/discord/linux.nix#L99>
      postFixup = ''
        wrapProgram $out/opt/${binaryName}/${binaryName} \
          --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--enable-features=UseOzonePlatform --ozone-platform=wayland}}" \
      '';
    });
in {
  canary = {
    home.packages = [ discordPackage ];

    xdg.configFile."discordcanary/settings.json".text = builtins.toJSON {
      openasar = {
        setup = true;
        cmdPreset = "balanced";
        quickstart = true;
        css = builtins.readFile
          "${bdAddons}/Themes/DiscordRecolor/DiscordRecolor.theme.css";
      };
      SKIP_HOST_UPDATE = true;
      IS_MAXIMIZED = false;
      IS_MINIMIZED = false;
      trayBalloonShown = false;
    };
  };
  webcord = { inputs, ... }: {
    imports = [ inputs.webcord.homeManagerModules.default ];

    programs.webcord = {
      enable = true;
      # use the one from nixpkgs,
      # probably more correct with dependencies & stuff
      package = pkgs.webcord;
      themes = {
        DiscordRecolor =
          "${bdAddons}/Themes/DiscordRecolor/DiscordRecolor.theme.css";
        # SettingsModal = "${bdAddons}/Themes/SettingsModal/SettingsModal.theme.css";
      };
    };
  };
}
