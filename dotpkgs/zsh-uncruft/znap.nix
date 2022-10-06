{
  config,
  lib,
  ...
}: let
  description = ''
    A lightweight plugin manager for ZSH.
    <https://github.com/marlonrichert/zsh-snap>
  '';
  cfg = config.programs.zsh-uncruft;
  znap = cfg.znap;
  inherit (lib) types;
in {
  options = {
    programs.zsh-uncruft.znap = {
      enable = lib.mkEnableOption description;

      pluginsDir = lib.mkOption {
        type = types.str;
        default = "${cfg.zdotdir}/plugins";
        example = lib.literalExpression ''
          "$HOME/.cache/znap_plugins"
        '';
        description = lib.mdDoc ''
          The directory that znap will clone plugins into.
        '';
      };

      autoUpdate = lib.mkEnableOption ''
        Enable znap automatic plugin updating.
      '';

      autoUpdateInterval = lib.mkOption {
        type = types.ints.positive;
        default = 7 * 24 * 60 * 60;
        example = lib.mdDoc ''
          `7 * 24 * 60 * 60` seconds (weekly)
        '';
        description = lib.mdDoc ''
          The duration (in seconds) between automatic plugin updates.
        '';
      };

      ## These options are disabled for now, as I don't expect anyone
      ## to want a fork. If necessary, I can simply uncomment and remove the
      ## variables defined below.
      #
      # gitUrl = lib.mkOption {
      #   type = types.str;
      #   default = "https://github.com/marlonrichert/zsh-snap";
      #   example = lib.literalExpression ''
      #     "https://github.com/marlonrichert/zsh-snap"
      #   '';
      #   description = lib.mdDoc ''
      #     The URL to the git repository to clone for znap.
      #   '';
      # };
      #
      # scriptPath = lib.mkOption {
      #   type = types.str;
      #   default = "${cfg.znap.pluginsDir}/zsh-snap/znap.zsh";
      #   example = lib.literalExpression ''
      #     "${cfg.znap.pluginsDir}/zsh-snap/znap.zsh"
      #   '';
      #   description = lib.mdDoc ''
      #     The path to the entry point (usually `znap.sh`) after cloning
      #     the repository. The repository will be cloned into
      #     `"$(dirname '$${scriptPath}')"`.
      #   '';
      # };
    };
  };

  config = lib.mkIf (cfg.enable && znap.enable) (lib.mkMerge [
    # this is mkBefore in the init stage, so the user will not have znap
    # available in preInit
    (let
      gitUrl = "https://github.com/marlonrichert/zsh-snap";
      scriptPath = "${znap.pluginsDir}/zsh-snap/znap.zsh";
    in {
      programs.zsh-uncruft.zshrc.init = lib.mkBefore ''
        ### DOWNLOAD AND SOURCE ZNAP ###

        [[ ! -d '${znap.pluginsDir}' ]] &&
          mkdir -p '${znap.pluginsDir}'

        [[ ! -f '${scriptPath}' ]] &&
          git clone '${gitUrl}' '${dirOf scriptPath}'

        source '${scriptPath}'

        ### END ###
      '';
    })
    # automatic updates go at the end of init, so mkAfter
    (lib.mkIf znap.autoUpdate (let
      lastUpdateFile = "${znap.pluginsDir}/.last_update";
    in {
      programs.zsh-uncruft.zshrc.init = lib.mkAfter ''
        ### AUTOMATIC UPDATE ZNAP PLUGINS ###

        [[ ! -f '${lastUpdateFile}' ]] &&
          echo 0 >'${lastUpdateFile}'

        local time_last_update="$(cat '${lastUpdateFile}')"
        local time_now="$(date '+%s')"
        local time_next_update="$((last_update + ${toString znap.autoUpdateInterval}))"

        if [[ "$time_now" -ge "$time_next_update" ]]; then
          znap pull
          echo "$time_now" >'${lastUpdateFile}'
        fi

        ### END ###
      '';
    }))
  ]);
}
