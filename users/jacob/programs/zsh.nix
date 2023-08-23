args@{ self, config, lib, pkgs, ... }:
let
  # FIXME git_colors based on git config
  nvimpager' = let
    super = pkgs.nvimpager;
    mainProgram = super.meta.mainProgram or super.pname;
  in pkgs.symlinkJoin {
    name = super.name;
    paths = [ super ];
    nativeBuildInputs = super.nativeBuildInputs or [ ] ++ [ pkgs.makeWrapper ];
    postBuild = super.postInstall or "" + ''
      wrapProgram $out/bin/${mainProgram} \
        --add-flags '-- -c "lua nvimpager.maps = false; nvimpager.git_colors = true"'
    '';
    meta = super.meta // { inherit mainProgram; };
  };

  plugins = {
    zsh-autosuggestions = pkgs.fetchFromGitHub {
      owner = "zsh-users";
      repo = "zsh-autosuggestions";
      rev = "v0.7.0";
      hash = "sha256-KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
    };
    zsh-autocomplete = pkgs.fetchFromGitHub {
      owner = "marlonrichert";
      repo = "zsh-autocomplete";
      rev = "23.07.13";
      hash = "sha256-0NW0TI//qFpUA2Hdx6NaYdQIIUpRSd0Y4NhwBbdssCs=";
    };
    zsh-edit = pkgs.fetchFromGitHub {
      owner = "marlonrichert";
      repo = "zsh-edit";
      rev = "9eb286982f96f03371488e910e42afb23802bdfd";
      hash = "sha256-LVHkH7fi8BQxLSeV+osdZzar1PQ0/hdb4yZ4oppGBoc=";
    };
    zsh-autopair = pkgs.fetchFromGitHub {
      owner = "hlissner";
      repo = "zsh-autopair";
      rev = "396c38a7468458ba29011f2ad4112e4fd35f78e6";
      hash = "sha256-PXHxPxFeoYXYMOC29YQKDdMnqTO0toyA7eJTSCV6PGE=";
    };
    zsh-auto-notify = pkgs.fetchFromGitHub {
      owner = "MichaelAquilina";
      repo = "zsh-auto-notify";
      rev = "22b2c61ed18514b4002acc626d7f19aa7cb2e34c";
      hash = "sha256-PXHxPxFeoYXYMOC29YQKDdMnqTO0toyA7eJTSCV6PGE=";
    };
    zsh-window-title = pkgs.fetchFromGitHub {
      owner = "olets";
      repo = "zsh-window-title";
      rev = "v1.0.2";
      hash = "sha256-efLpDY+cIe2KhRFpTcm85mYUFlTa2ECTIFhP7hjuf+8=";
    };
    fast-syntax-highlighting = pkgs.fetchFromGitHub {
      owner = "zdharma-continuum";
      repo = "fast-syntax-highlighting";
      rev = "cf318e06a9b7c9f2219d78f41b46fa6e06011fd9";
      hash = "sha256-RVX9ZSzjBW3LpFs2W86lKI6vtcvDWP6EPxzeTcRZua4=";
    };
  };
in {
  imports = [ self.homeManagerModules.zsh ];

  home.packages = [ pkgs.most nvimpager' ];

  programs.starship = {
    enable = true;
    settings = import ./starship.nix args;
    enableBashIntegration = lib.mkDefault false;
    enableFishIntegration = lib.mkDefault false;
    enableIonIntegration = lib.mkDefault false;
    enableZshIntegration = lib.mkDefault false;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = lib.mkDefault false;
    enableFishIntegration = lib.mkDefault false;
    enableZshIntegration = true;
  };

  programs.lsd = {
    enable = true;
    enableAliases = true;
  };

  xdg.configFile = lib.mapAttrs' (name: source: {
    name = "zsh/plugins/${name}";
    value = { inherit source; };
  }) plugins;

  programs.zsh.alt = {
    # allow other home manager modules to integrate
    enableIntegrations = true;
    enableAliases = true;

    zshrc.preInit = ''
      # Referenced <https://github.com/mattmc3/zsh_unplugged>.
      function plugin-load {
        : ''${ZPLUGINDIR:=''${ZDOTDIR:-~/.config/zsh}/plugins}
        plugname=$1
        plugdir=$ZPLUGINDIR/$plugname
        initfile=$plugdir/$plugname.plugin.zsh
        if [[ ! -f $initfile ]]; then
          initfiles=($plugdir/*.{plugin.zsh,zsh-theme,zsh,sh}(N))
          (( $#initfiles )) || { echo >&2 "No init file for '$plugname'." && continue }
          initfile=$initfiles[1]
        fi
        fpath+=$plugdir
        source $initfile
      }
    '';

    zshrc.init = ''
      ### PROMPT ###

      # Prompt is at the top so that I can start typing right away.
      # Ignore if in TTY.
      if ! tty | grep '/dev/tty[0-9]\?'; then
        eval "$(
          ${lib.getExe config.programs.starship.package} \
            init zsh --print-full-init
        )"
        # This was here to eliminate the 2-space padding on the right of
        # the prompt. No longer needed because there's nothing at the end.
        # <https://github.com/starship/starship/issues/4358>
        # PROMPT="''${PROMPT//\$COLUMNS/\$((COLUMNS+2))}"
        ZLE_RPROMPT_INDENT=0
      fi

      ### COMPLETION ###

      setopt AUTO_CD
      setopt ALWAYS_TO_END

      ### GLOBBING ###

      setopt BAD_PATTERN
      setopt EXTENDED_GLOB
      setopt GLOB_DOTS
      setopt GLOB_STAR_SHORT
      setopt NULL_GLOB

      ### HISTORY ###

      HISTFILE=$ZDOTDIR/.zsh_history
      HISTSIZE=1000000
      SAVEHIST=$HISTSIZE

      setopt EXTENDED_HISTORY
      setopt HIST_FCNTL_LOCK
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_REDUCE_BLANKS
      setopt HIST_SAVE_NO_DUPS
      setopt SHARE_HISTORY

      ### INTERACTION ###

      setopt INTERACTIVE_COMMENTS
      setopt RM_STAR_SILENT
    '';

    zshrc.main = ''
      ### AUTOCOMPLETE ###

      # Disable security checks.
      # Needed to avoid warnings about sourcing "insecure"
      # files from `/nix/store`.
      zstyle '*:compinit' arguments -C

      zstyle ':autocomplete:*' min-delay 0.5
      zstyle ':autocomplete:*' min-input 1
      zstyle ':autocomplete:*' insert-unambiguous yes
      zstyle ':autocomplete:*' fzf-completion yes

      plugin-load zsh-autocomplete

      zstyle ':completion:*:paths' path-completion yes

      plugin-load zsh-autopair

      ### AUTOSUGGEST ###

      ZSH_AUTOSUGGEST_STRATEGY=(history completion)

      plugin-load zsh-autosuggestions

      ### SYNTAX HIGHLIGHTING ###

      plugin-load fast-syntax-highlighting

      PAGER='${lib.getExe nvimpager'}'

      ### KEYBINDINGS ###

      plugin-load zsh-edit

      ### NOTIFICATIONS ###

      AUTO_NOTIFY_THRESHOLD=300
      AUTO_NOTIFY_TITLE='Command has completed!'
      AUTO_NOTIFY_BODY='<i>%command</i>'
      AUTO_NOTIFY_BODY+='\n'
      AUTO_NOTIFY_BODY+='With exit code %exit_code after %elapsed seconds.'
      AUTO_NOTIFY_EXPIRE_TIME=15000

      plugin-load zsh-auto-notify

      ### WINDOW TITLE ###

      ZSH_WINDOW_TITLE_DIRECTORY_DEPTH=4

      plugin-load zsh-window-title
    '';
  };
}
