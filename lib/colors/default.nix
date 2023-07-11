{ lib }:
let
  rgbAttrsToHexStr = { r, g, b }:
    (lib.intToHex r) + (lib.intToHex g) + (lib.intToHex b);

  gruvbox = import ./palettes/gruvbox.nix { inherit lib; };
in {
  rgb = { inherit gruvbox; };
  hex = {
    gruvbox = {
      colors = lib.mapAttrs (_: rgbAttrsToHexStr) gruvbox.colors;
      light = lib.mapAttrs (_: rgbAttrsToHexStr) gruvbox.light;
      dark = lib.mapAttrs (_: rgbAttrsToHexStr) gruvbox.dark;
    };
  };
}
