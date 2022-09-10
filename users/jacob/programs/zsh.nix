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
    znap.autoUpdate = true;
    zshrc.init = ''
      znap eval starship '${lib.getExe pkgs.starship} init zsh --print-full-init'
      znap prompt
    '';
    zshrc.main = ''
      znap source marlonrichert/zsh-autocomplete
      znap source zsh-users/zsh-autosuggestions
      znap source zsh-users/zsh-syntax-highlighting
    '';
  };
}
