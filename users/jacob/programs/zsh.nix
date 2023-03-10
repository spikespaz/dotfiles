args @ {
  self,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [self.homeManagerModules.zsh];

  home.packages = [pkgs.most];

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

  programs.zsh.alt = {
    znap.enable = true;
    # automatically update every two weeks
    znap.autoUpdate = true;
    znap.autoUpdateInterval = 2 * 7 * 24 * 60 * 60;

    # allow other home manager modules to integrate
    enableIntegrations = true;
    enableAliases = true;

    zshrc.init = ''
      if ! tty | grep '/dev/tty[0-9]\?'; then
        znap eval starship '${lib.getExe pkgs.starship} init zsh --print-full-init'
        # <https://github.com/starship/starship/issues/4358>
        # PROMPT="''${PROMPT//\$COLUMNS/\$((COLUMNS+2))}"
        ZLE_RPROMPT_INDENT=0
        znap prompt
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

      zstyle ':autocomplete:*' min-delay 0.5
      zstyle ':autocomplete:*' min-input 1
      zstyle ':autocomplete:*' insert-unambiguous yes
      zstyle ':autocomplete:*' fzf-completion yes

      znap source marlonrichert/zsh-autocomplete

      zstyle ':completion:*:paths' path-completion yes

      ### AUTOSUGGEST ###

      ZSH_AUTOSUGGEST_STRATEGY=(history completion)
      znap source zsh-users/zsh-autosuggestions
      znap source hlissner/zsh-autopair

      ### SYNTAX HIGHLIGHTING ###

      znap source zdharma-continuum/fast-syntax-highlighting
      # znap source z-shell/F-Sy-H

      PAGER='${lib.getExe pkgs.most}'

      ### KEYBINDINGS ###

      znap source marlonrichert/zsh-edit

      ### NOTIFICATIONS ###

      AUTO_NOTIFY_THRESHOLD=300
      AUTO_NOTIFY_TITLE='Command has completed!'
      AUTO_NOTIFY_BODY='<i>%command</i>'
      AUTO_NOTIFY_BODY+='\n'
      AUTO_NOTIFY_BODY+='With exit code %exit_code after %elapsed seconds.'
      AUTO_NOTIFY_EXPIRE_TIME=15000
      znap source michaelaquilina/zsh-auto-notify

      ### WINDOW TITLE ###

      ZSH_WINDOW_TITLE_DIRECTORY_DEPTH=4
      znap source olets/zsh-window-title
    '';
  };
}
