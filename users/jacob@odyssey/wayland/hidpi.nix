{ lib, ... }: {
  home.sessionVariables = {
    GDK_SCALE = lib.mkForce 2;
    STEAM_FORCE_DESKTOPUI_SCALING = "1.5";
  };

  systemd.user.services.steam.Service.Environment = "GDK_SCALE=1";
}
