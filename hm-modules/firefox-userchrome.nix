{ lib, pkgs, config, ... }:
let
  inherit (lib) types;
  cfg = config.programs.firefox.userChrome;

  jsonFormat = pkgs.formats.json { };

  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  mozillaConfigPath =
    if isDarwin then "Library/Application Support/Mozilla" else ".mozilla";

  firefoxConfigPath = if isDarwin then
    "Library/Application Support/Firefox"
  else
    "${mozillaConfigPath}/firefox";

  profilesPath =
    if isDarwin then "${firefoxConfigPath}/Profiles" else firefoxConfigPath;
in {
  options = {
    programs.firefox.userChrome = {
      profiles = lib.mkOption {
        type = types.attrsOf (types.submodule ({ config, name, ... }: {
          options = {
            profile = lib.mkOption {
              type = types.singleLineStr;
              default = name;
              readOnly = true;
              description = ''
                This is expected to be the attribute path segment used in
                {option}`programs.firefox.profiles.''${profile}`.
              '';
            };
            settings = lib.mkOption {
              type = jsonFormat.type;
              default = {
                "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
                "layout.css.has-selector.enabled" = true;
              };
              description = ''
                Settings to merge with
                {option}`programs.firefox.profiles.''${profile}.settings`.
              '';
            };
            extraSettings = lib.mkOption {
              type = jsonFormat.type;
              default = { };
              description = ''
                Extra settings so you don't have to override the default
                {option}`settings`.
              '';
            };
            source = lib.mkOption {
              type = types.nullOr (types.either types.path types.package);
              default = null;
              description = ''
                The source derivation for the `chrome` directory.
              '';
            };
            recursive = lib.mkOption {
              type = types.bool;
              default = false;
            };
            # No text option because HM has it
          };
        }));
        default = { };
      };
    };
  };

  config = lib.mkIf (cfg.profiles != { }) {
    programs.firefox.profiles = lib.mapAttrs (_: profile: {
      settings = profile.settings // profile.extraSettings;
      userChrome = lib.mkForce "";
      userContent = lib.mkForce "";
    }) cfg.profiles;

    home.file = lib.mapAttrs' (_: profile: {
      name = if lib.pathIsRegularFile profile.source then
        "${profilesPath}/${profile.profile}/chrome/userChrome.css"
      else
        "${profilesPath}/${profile.profile}/chrome";
      value = { inherit (profile) source recursive; };
    }) cfg.profiles;
  };
}
