{
  self,
  home-manager,
  pkgs,
  ulib,
  hmModules,
}:
home-manager.lib.homeManagerConfiguration {
  inherit pkgs;

  extraSpecialArgs = {
    inherit self ulib hmModules;
  };

  modules = let
    desktops = import ./desktops ulib;
  in [
    ./profile.nix
    desktops.hyprland
    desktops.software
    desktops.mimeApps
  ];
}
