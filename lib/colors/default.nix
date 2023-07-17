{ lib }:
let
  rgbAttrsToHexStr = { r, g, b }:
    (lib.intToHex r) + (lib.intToHex g) + (lib.intToHex b);

  gruvbox = import ./palettes/gruvbox.nix { inherit lib; };
in {
  palettes = { inherit gruvbox; };
}
