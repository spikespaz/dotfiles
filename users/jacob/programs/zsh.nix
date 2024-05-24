args@{ self, config, lib, pkgs, ... }:
let
  # # FIXME git_colors based on git config
  # nvimpager' = let
  #   super = pkgs.nvimpager;
  #   mainProgram = super.meta.mainProgram or super.pname;
  # in pkgs.symlinkJoin {
  #   name = super.name;
  #   paths = [ super ];
  #   nativeBuildInputs = super.nativeBuildInputs or [ ] ++ [ pkgs.makeWrapper ];
  #   postBuild = super.postInstall or "" + ''
  #     wrapProgram $out/bin/${mainProgram} \
  #       --add-flags '-- -c "lua nvimpager.maps = false; nvimpager.git_colors = true"'
  #   '';
  #   meta = super.meta // { inherit mainProgram; };
  # };

  plugins = {
    inherit (pkgs.zsh-plugins)
      zsh-autosuggestions zsh-autocomplete zsh-edit zsh-autopair zsh-auto-notify
      zsh-window-title zsh-fast-syntax-highlighting;
  };
in {
  imports = [ self.homeManagerModules.zsh ];

  home.packages = [ pkgs.most ];

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

  xdg.configFile = lib.mapAttrs' (_: source: {
    name = "zsh/plugins/${source.pname}";
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

      PAGER='less'

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

      ### MISCELLANEOUS ###

      source ${pkgs.nix-your-shell.generate-config "zsh"}
    '';
  };
}
