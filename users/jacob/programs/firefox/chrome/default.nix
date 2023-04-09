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
  home.file."${profilesPath}/${profile}/chrome" = {
    source = pkgs.stdenvNoCC.mkDerivation {
      name = "firefox-chrome";
      phases = ["installPhase"];
      installPhase =
        lib.concatMapStrings (
          {
            # The `attrNames` in `chrome.sources` are target
            # directories relative to `$out`.
            name,
            # The `attrValues` are the path-strings to the source to copy.
            value,
          }: ''
            if [[ -d '${value}' ]]; then
              mkdir -p "$out/${name}"
              cp -Rs '${value}' -T "$out/${name}"
            elif [[ -f '${value}' ]]; then
              mkdir -p "$out/${name}/.."
              ln -s '${value}' "$out/${name}"
            else
              echo 'What is this file?'
            fi
          ''
        ) (lib.mapAttrsToList lib.nameValuePair chrome.sources)
        + ''
          (
            shopt -s extglob
            ${lib.toShellVar "blacklistGlobs" chrome.blacklistGlobs}
            for glob in "''${blacklistGlobs[@]}"; do
              rm -rf $out/$glob
            done
          )
        '';
    };
    # this is just so that the end-user can delete individual
    # files to try things.
    # the chrome dir will be RW
    recursive = true;
  };

  programs.firefox.profiles.${profile} = {
    settings = chrome.userConfig;
    userChrome = lib.mkForce "";
    userContent = lib.mkForce "";
  };
}
