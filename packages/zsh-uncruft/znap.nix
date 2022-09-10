{ config, lib, ... }: let
  description = ''
    A lightweight plugin manager for ZSH.
    <https://github.com/marlonrichert/zsh-snap>
  '';
  cfg = config.programs.zsh-uncruft;
in {
  options = let
    inherit (lib) types;
  in {
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

  config = with cfg.znap; lib.mkIf enable (
    let
      gitUrl = "https://github.com/marlonrichert/zsh-snap";
      scriptPath = "${cfg.znap.pluginsDir}/zsh-snap/znap.zsh";
      lastUpdateFile = "${pluginsDir}/.last_update";
    in {
      home.file."${cfg.zdotdir}/.zshrc".text = lib.mkOrder 900 ''
        [[ ! -d '${pluginsDir}' ]] &&
          mkdir -p '${pluginsDir}'

        ${lib.optionalString autoUpdate ''
          [[ ! -f '${lastUpdateFile}' ]] &&
            echo 0 >'${lastUpdateFile}'
        ''}

        [[ ! -f '${scriptPath}' ]] &&
          git clone '${gitUrl}' '${dirOf scriptPath}'

        source '${scriptPath}'

        ${lib.optionalString autoUpdate ''
          local time_last_update="$(cat '${lastUpdateFile}')"
          local time_now="$(date '+%s')"
          local time_next_update="$((last_update + ${toString autoUpdateInterval}))"

          if [[ "$time_now" -ge "$time_next_update" ]]; then
            znap pull
            echo "$time_now" >'${lastUpdateFile}'
          fi
        ''}
      '';
    }
  );
}
