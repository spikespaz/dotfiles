profile: args @ {
  config,
  pkgs,
  lib,
  ...
}: let
  chrome = import ./chrome.nix args;

  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  mozillaConfigPath =
    if isDarwin
    then "Library/Application Support/Mozilla"
    else ".mozilla";

  firefoxConfigPath =
    if isDarwin
    then "Library/Application Support/Firefox"
    else "${mozillaConfigPath}/firefox";

  profilesPath =
    if isDarwin
    then "${firefoxConfigPath}/Profiles"
    else firefoxConfigPath;
in {
  home.file."${profilesPath}/${profile}/chrome".source = pkgs.symlinkJoin {
    name = "firefox-chrome";
    paths = chrome.sources;
  };

  programs.firefox.profiles.${profile} = {
    settings = chrome.userConfig;
    userChrome = lib.mkForce "";
    userContent = lib.mkForce "";
  };
}
