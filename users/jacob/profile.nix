{ pkgs, inputs, ... }: {
  imports = [
    inputs.hyprland.homeManagerModules.default
  ];

  home.username = "jacob";
  home.homeDirectory = "/home/jacob";

  home.packages = with pkgs; [
    # Email
    thunderbird
    # Messaging
    discord
    neochat
    # Text Editors
    vscode

    # Office Suite
    onlyoffice-bin

    # Desktop Theming
    papirus-icon-theme
    materia-theme
    materia-kde-theme
    libsForQt5.qtstyleplugin-kvantum
  ];

  wayland.windowManager.hyprland = {
    enable = true;
  };

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

  programs.hexchat = {
    enable = true;
  };

  programs.obs-studio = {
    enable = true;
  };

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
  };

  home.stateVersion = "22.05";
}
