{ config, lib, ... }: let
  cfg = config.programs.zsh-uncruft;
in {
  options = {
    programs.zsh-uncruft = {
      enableIntegrations = lib.mkEnableOption ''
        Enable integrations from other Home Manager modules.
      '';

      enableAliases = lib.mkEnableOption ''
        Enable aliases defined by other Home Manager modules.
      '';
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [

    (lib.mkIf cfg.enableIntegrations {
      programs.zsh-uncruft.zshrc.postInit = ''
        ### HOME MANAGER EXTRA INITIALIZATION ###

        ${config.programs.zsh.initExtra}

        ### END ###
      '';
    })

    (lib.mkIf cfg.enableAliases {
      programs.zsh-uncruft.zshrc.main = lib.mkAfter
        (lib.concatStringsSep "\n" (builtins.concatLists [
          (lib.singleton "### HOME MANAGER ALIASES ###\n")
          (lib.mapAttrsToList
            (k: v: "alias ${k}=${lib.escapeShellArg v}")
            config.programs.zsh.shellAliases)
          (lib.mapAttrsToList
            (k: v: "alias -g ${k}=${lib.escapeShellArg v}")
            config.programs.zsh.shellGlobalAliases)
          (lib.singleton "\n### END ###")
        ]));
    })

  ]);
}
