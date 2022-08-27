# DOCUMENTATION
# <https://nix-community.github.io/home-manager/options.html>
# REFERENCES
# <https://github.com/MatthewCroughan/nixcfg>
{ config, pkgs, nixpkgs, ... }:
  # let
  #   mkHyprEnvVars = { vars, index ? 0, head ? "" }:
  #     if index < builtins.length (builtins.attrNames vars) then
  #       mkHyprEnvVars {
  #         inherit vars;
  #         index = index + 1;
  #         head = head + "exec-once=export ${builtins.elemAt (builtins.attrNames vars) index}='${builtins.toString (builtins.elemAt (builtins.attrValues vars) index)}'\n";
  #       }
  #     else
  #       head + "\n";
  # in
{
  # <https://github.com/nix-community/home-manager/issues/2942>
  #nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true;

  home.username = "jacob";
  home.homeDirectory = "/home/jacob";

  xdg.enable = true;
  xdg.userDirs.enable = true;
  xdg.userDirs.createDirectories = true;

  home.packages = with pkgs; [
    # Diagnostics
    wev
    neofetch

    # Email
    thunderbird
    # Messaging
    discord
    neochat

    # Office Suite
    onlyoffice-bin

    # Desktop Themes
    materia-kde-theme
  ];

  xdg.configFile."hypr/hyprland.conf".text = builtins.readFile ./configs/hyprland.conf;

  gtk = {
    enable = true;

    cursorTheme.package = pkgs.quintom-cursor-theme;
    cursorTheme.name = "Quintom_Ink";

    iconTheme.package = pkgs.papirus-icon-theme;
    iconTheme.name = "Papirus-Dark";

    theme.package = pkgs.materia-theme;
    theme.name = "Materia-dark-compact";
  };

  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=MateriaDark
  '';

  # home.sessionVariables = {
  #   QT_QPA_PLATFORM = "wayland";
  #   #XDG_CURRENT_DESKTOP = "sway"
  #   #XDG_SESSION_DESKTOP = "sway"
  #   #XDG_CURRENT_SESSION_TYPE = "wayland"
  #   QT_QPA_PLATFORMTHEME = "qt5ct";
  #   QT_STYLE_OVERRIDE = "kvantum";
  #   GTK_USE_PORTAL = 1;
  #   MOZ_ENABLE_WAYLAND = 1;
  #   _JAVA_AWT_WM_NONREPARENTING = 1;
  #   XCURSOR_SIZE = 24;
  # };

  # pam.sessionVariables = config.home.sessionVariables;
  
  # xdg.configFile."hypr/hyprland.conf".text =
  #   (mkHyprEnvVars { vars = config.home.sessionVariables; })
  #   + (builtins.readFile ./configs/hyprland.conf);

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Jacob Birkett";
    userEmail = "jacob@birkett.dev";

    delta.enable = true;
  };

  programs.bat = {
    enable = true;
  };

  programs.exa = {
    enable = true;
  };

  programs.lsd = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
  };

  programs.firefox = {
    enable = true;
  };

  programs.chromium = {
    enable = true;
  };

  programs.helix = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
  };

  programs.vscode = {
    enable = true;
  };

  programs.hexchat = {
    enable = true;
  };

  programs.obs-studio = {
    enable = true;
  };

  home.stateVersion = "22.05";
}
