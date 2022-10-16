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
  blackish = "1d1d1d";
  slighter = "212121";
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
      text = gruvbox.fg0;
      subtext = gruvbox.fg1;
      nav-active-text = gruvbox.bg0_h;
      main = blackish;
      sidebar = slighter;
      player = slighter;
      card = gruvbox.fg4;
      shadow = gruvbox.bg1;
      main-secondary = gruvbox.bg0_s;
      button = gruvbox.orange;
      button-secondary = gruvbox.blue;
      button-active = gruvbox.normal.orange;
      button-disabled = gruvbox.fg4;
      nav-active = gruvbox.normal.orange;
      play-button = gruvbox.aqua;
      tab-active = gruvbox.bg0_h;
      notification = gruvbox.fg3;
      notification-error = gruvbox.fg3;
      playback-bar = gruvbox.blue;
      misc = "FFFFFF";
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
