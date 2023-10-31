{ lib }:
let
  # Taking R, G, and B arguments in range 0-255, produce an attribute set.
  rgb = r: g: b: { inherit r g b; };

  # Produces a hexadecimal RRGGBBAA color from an attributes.
  # Each channel value is expected to be between 0-255.
  # Alpha attribute `a` is not required and may be undefined or null.
  hexRGBA = { r, g, b, a ? null }:
    lib.concatStrings (map (c: lib.lpadString "0" 2 (lib.intToHex c))
      ([ r g b ] ++ lib.optional (a != null) a));

  # Like `hexRGBA` but takes alpha as float in a separate argument.
  hexRGBA' = rgb: a:
    let a' = builtins.floor (a * 255);
    in hexRGBA (rgb // { a = a'; });

  palettes = { gruvbox = import ./palettes/gruvbox.nix { inherit rgb; }; };

  isRGBAttrs = expr: lib.isAttrs expr && lib.hasExactAttrs [ "r" "g" "b" ] expr;

  # Recurse deeply into attrs and lists, and transform each RGB attrs by `op`.
  transformPalette = op:
    lib.mapRecursiveCond (expr: !(isRGBAttrs expr))
    (_: expr: if isRGBAttrs expr then op expr else expr);
in rec {
  # FUNCTIONS #
  inherit rgb hexRGBA hexRGBA';
  # COLORS #
  inherit palettes;
  formats = {
    hexRGB = transformPalette (rgb: hexRGBA rgb) palettes;
    hexRGB' = transformPalette (rgb: "#${hexRGBA rgb}") palettes;
  };
}
