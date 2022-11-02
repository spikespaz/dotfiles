{
  pkgs,
  lib,
  hmModules,
  ...
}: let
  officialThemes = pkgs.fetchFromGitHub {
    owner = "spicetify";
    repo = "spicetify-themes";
    rev = "eb6b818368d9c01ef92522623b37aa29200d0bc0";
    sha256 = "sha256-Q/LBS+bjt2WP/s43LE8hDjYHxPVorT/RA71esPraLOM=";
  };

  gruvbox = {
    normal = {
      orange = "d65d0e";
      red = "cc241d";
      green = "98971a";
      yellow = "d79921";
      blue = "458588";
      purple = "b16286";
      aqua = "689d6a";
      gray = "a89984";
    };
    bright = {
      red = "fb4934";
      green = "b8bb26";
      yellow = "fabd2f";
      blue = "83a598";
      purple = "d3869b";
      aqua = "8ec07c";
      orange = "fe8019";
      gray = "928374";
    };
    bg = gruvbox.bg0;
    bg0 = "282828";
    bg0_h = "1d2021";
    bg0_s = "32302f";
    bg1 = "3c3836";
    bg2 = "504945";
    bg3 = "665c54";
    bg4 = "7c6f64";
    fg = gruvbox.fg1;
    fg0 = "fbf1c7";
    fg1 = "ebdbb2";
    fg2 = "d5c4a1";
    fg3 = "bdae93";
    fg4 = "a89984";
    inherit (gruvbox.bright) orange red green yellow blue purple aqua gray;
  };
  blackish = "141414";
  slighter = "1e1e1e";
in {
  imports = [hmModules.spicetify];

  programs.spicetify = {
    enable = true;
    # spotifyPackage = pkgs.spotify;
    theme = {
      name = "Onepunch";
      src = officialThemes;
      appendName = true;
      injectCss = true;
      replaceColors = true;
      overwriteAssets = true;
      sidebarConfig = true;
    };
    colorScheme = "custom";
    customColorScheme = {
      ### onepunch gruvbox
      text = gruvbox.fg0;
      subtext = gruvbox.bright.aqua;
      extratext = gruvbox.fg2;
      main = blackish;
      sidebar = slighter;
      player = blackish;
      sec-player = gruvbox.bg0_s;
      card = gruvbox.bg0_h;
      sec-card = gruvbox.bright.orange;
      shadow = blackish;
      selected-row = gruvbox.bright.blue;
      button = gruvbox.normal.green;
      button-active = gruvbox.normal.green;
      button-disabled = gruvbox.bg3;
      tab-active = gruvbox.normal.orange;
      notification = gruvbox.normal.orange;
      notification-error = gruvbox.bright.red;
      misc = gruvbox.normal.blue;

      ### onepunch dark mode
      # text               = d5c4a1
      # subtext            = b8bb26
      # extratext          = fabd2f
      # main               = 1d2021
      # sidebar            = 1d2021
      # player             = 1d2021
      # sec-player         = 32302f
      # card               = 32302f
      # sec-card           = fb4934
      # shadow             = 1d2021
      # selected-row       = d3869b
      # button             = 8ec07c
      # button-active      = 8ec07c
      # button-disabled    = 665c54
      # tab-active         = fb4934
      # notification       = fb4934
      # notification-error = cc2418
      # misc               = 83a598
    };
    enabledExtensions = [
      # "fullAppDisplay.js"
      # "shuffle+.js"
      # "hidePodcasts.js"
      # "popupLyrics.js"
      "seekSong.js"
      # "skipOrPlayLikedSongs.js"
      # "playlistIcons.js"
      # "listPlaylistsWithSong.js"
      # "playlistIntersection.js"
      # "featureShuffle.js"
      # "showQueueDuration.js"
      # "copyToClipboard.js"
      # "history.js"
      # "genre.js"
      # "autoSkip.js"
      # "playNext.js"
    ];
  };
}
