ulib: {
  hyprland = {
    imports = [
      ./wayland
      ./hyprland
    ];
  };

  software = {
    imports = [
      ./suite.nix
    ];
  };

  mimeApps = ulib.importMimeApps ./mimeapps.nix;
}
