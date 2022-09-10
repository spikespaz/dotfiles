{ config, lib, pkgs, dotpkgs, ... }: {
  imports = [ dotpkgs.homeManagerModules.zsh-uncruft ];

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

  programs.starship = {
    enable = true;
    settings = {
      scan_timeout = 100;
      command_timeout = 1000;
    };
  };
}
