args @ { config, lib, pkgs, dotpkgs, ... }: {
  imports = [ dotpkgs.homeManagerModules.zsh-uncruft ];

  programs.starship = {
    enable = true;
    settings = import ./starship.nix args;
    enableBashIntegration = lib.mkDefault false;
    enableFishIntegration = lib.mkDefault false;
    enableIonIntegration = lib.mkDefault false;
    enableZshIntegration = lib.mkDefault false;
  };

  programs.zsh-uncruft = {
    znap.enable = true;
    # automatically update every two weeks
    znap.autoUpdate = true;
    znap.autoUpdateInterval = 2 * 7 * 24 * 60 * 60;

    # allow other home manager modules to integrate
    enableIntegrations = true;

    zshrc.preInit = ''
      bindkey '^[[3~' delete-char
    '';
    
    zshrc.init = ''
      ZLE_RPROMPT_INDENT=0

      znap eval starship '${lib.getExe pkgs.starship} init zsh --print-full-init'
      znap prompt

      HISTSIZE=1000000
      SAVEHIST=$HISTSIZE

      # completion
      setopt AUTO_CD
      setopt ALWAYS_TO_END
      # globbing
      setopt BAD_PATTERN
      setopt EXTENDED_GLOB
      setopt GLOB_DOTS
      setopt GLOB_STAR_SHORT
      setopt NULL_GLOB
      # history
      setopt EXTENDED_HISTORY
      setopt HIST_FCNTL_LOCK
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_REDUCE_BLANKS
      setopt HIST_SAVE_NO_DUPS
      setopt SHARE_HISTORY
      # interaction
      setopt INTERACTIVE_COMMENTS
      setopt RM_STAR_SILENT
      # line editor
      setopt VI
    '';

    zshrc.main = ''
      ### AUTOCOMPLETE ###

      zstyle ':autocomplete:*' min-delay 0.5
      zstyle ':autocomplete:*' min-input 1
      zstyle ':autocomplete:*' insert-unambiguous yes
      zstyle ':autocomplete:*' fzf-completion yes

      znap source marlonrichert/zsh-autocomplete

      zstyle ':completion:*:paths' path-completion yes

      ### MISCELLANEOUS ###

      ZSH_AUTOSUGGEST_STRATEGY=(history completion)
      znap source zsh-users/zsh-autosuggestions
      znap source zsh-users/zsh-syntax-highlighting
      znap source hlissner/zsh-autopair
    '';
  };
}
