{ lib }:
let
  # Taking R, G, and B arguments in range 0-255, produce an attribute set.
  rgb = r: g: b: { inherit r g b; };

  # Produces a hexadecimal RRGGBBAA color from an attributes.
  # Each channel value is expected to be between 0-255.
  # Alpha attribute `a` is not required and may be undefined or null.
  hexRGB = { r, g, b, a ? null }:
    lib.concatStrings (map (c: lib.lpadString "0" 2 (lib.intToHex c))
      ([ r g b ] ++ lib.optional (a != null) a));

  # Like `hexRGB` but takes alpha as float in a separate argument.
  hexRGBA = rgb: a:
    let a' = builtins.floor (a * 255);
    in hexRGB (rgb // { a = a'; });

  palettes = { gruvbox = import ./palettes/gruvbox.nix { inherit rgb; }; };

  isRGBAttrs = expr: lib.isAttrs expr && lib.hasExactAttrs [ "r" "g" "b" ] expr;

  # Recurse deeply into attrs and lists, and transform each RGB attrs by `op`.
  transformPalette = op:
    lib.mapRecursiveCond (expr: !(isRGBAttrs expr))
    (_: expr: if isRGBAttrs expr then op expr else expr);
in rec {
  # FUNCTIONS #
  inherit rgb hexRGB hexRGBA;
  # COLORS #
  inherit palettes;
  formats = {
    hexRGB = transformPalette hexRGB palettes;
    hexRGB' = transformPalette (rgb: "#${hexRGB rgb}") palettes;
  };
}
