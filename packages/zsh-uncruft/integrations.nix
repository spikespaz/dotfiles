{ config, lib, ... }: let
  cfg = config.programs.zsh-uncruft;
in {
  imports = [
    ./znap.nix
  ];

  options = {
    programs.zsh-uncruft = {
      enableIntegrations = lib.mkEnableOption ''
        Enable integrations from other Home Manager modules.
      '';
    };
  };

  config = lib.mkIf (cfg.enable && cfg.enableIntegrations) {
    programs.zsh-uncruft.zshrc.postInit = config.programs.zsh.initExtra;
  };
}
