# Adapted from Fufexan's webcord-flake:
# <https://github.com/fufexan/webcord-flake>
#
# I am appointing myself the new maintainer,
# as the original author no longer uses WebCord.
#
# Both `webcord` and `webcord-vencord` packages are
# maintained in Nixpkgs, so those will be used from now on
# instead of the original `dream2nix` one.
#
{ config, pkgs, lib, ... }:
let
  inherit (lib) types;
  cfg = config.programs.webcord;
in {
  options = {
    programs.webcord = {
      enable = lib.mkEnableOption cfg.package.meta.description;

      package = lib.mkPackageOptionMD pkgs [ "webcord" ] {
        example = [ "webcord-vencord" ];
      };

      themes = lib.mkOption {
        type = types.attrsOf types.path;
        default = { };
        description = lib.mdDoc ''
          An attribute set of themes, where each key is the name of the
          theme when linked into {path}`$XDG_CONFIG_HOME/WebCord/Themes`,
          and the value is the file path of the CSS source.

          *This will need to change once the
          [feature](https://github.com/SpacingBat3/WebCord/blob/master/docs/Features.md#1-custom-discord-styles)
          is stabilized.*
        '';
        example = lib.literalExpression ''
          let
            repo = pkgs.fetchFromGitHub {
              owner = "mwittrien";
              repo = "BetterDiscordAddons";
              rev = "8627bb7f71c296d9e05d82538d3af8f739f131dc";
              sha256 = "sha256-Dn6igqL0GvaOcTFZOtQOxuk0ikrWxyDZ41tNsJXJAxc=";
            };

            themes = {
              discord-recolor = "''${repo}/Themes/DiscordRecolor/DiscordRecolor.theme.css";
              settings-modal = "''${repo}/Themes/SettingsModal/SettingsModal.theme.css";
            };
          in {
            DiscordRecolor = themes.discord-recolor;
            SettingsModal = themes.settings-modal;
          }
        '';
      };

      deleteThemes = lib.mkEnableOption (lib.mdDoc ''
        Whether to enable the DAG entry to delete files in the `Themes`
        directory before creating new links.

        Note that this is not necessary to mitigate the issue with WebCord
        not cleaning up, because all symlinks created by Nix will be re-created
        upon a generation switch.

        Only enable this if for some reason you don't want to be able to add
        files to the `Themes` directory manually.

        **The `Themes` directory contents will be permanently deleted**
        when activating a new generation!
      '');
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # add the package
    {
      home.packages = [ cfg.package ];
    }

    # handle the themes if any
    (lib.mkIf (cfg.themes != { }) {
      # for every theme provided, create a symlink in the conf dir
      # to the path provided (see themes opt description)
      xdg.configFile = lib.mapAttrs' (name: source: {
        name = "WebCord/Themes/${name}";
        value = { inherit source; };
      }) cfg.themes;
    })

    # add a DAG entry to remove the themes that are not managed
    (lib.mkIf (cfg.deleteThemes) {
      home.activation = {
        rmWebCordThemes = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
          $DRY_RUN_CMD rm -rf $VERBOSE_ARG \
            ${config.xdg.configHome}/WebCord/Themes/*
        '';
      };
    })
  ]);
}
