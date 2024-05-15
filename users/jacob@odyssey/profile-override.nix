args@{ lib, pkgs, ... }: {
  home.sessionVariables = { GDK_SCALE = lib.mkForce 2; };
  programs.vscode.userSettings = { "editor.fontSize" = lib.mkForce 14; };
  systemd.user.services.steam.Service.Environment = "GDK_SCALE=1";
  imports = let
    user = lib.importDir' ../jacob "profile.nix";
    programs = user.programs args;
    services = user.services args;
  in [ services.steam ];
}
