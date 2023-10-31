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

  # Same as `hexRGB` but prefix with `#`.
  hexRGB' = rgb: "#${hexRGB rgb}";

  # Like `hexRGB` but takes alpha as float in a separate argument.
  hexRGBA = rgb: a:
    let a' = builtins.floor (a * 255);
    in hexRGB (rgb // { a = a'; });

  # Like `hexRGBA` but prefix with `#`.
  hexRGBA' = rgb: a: "#${hexRGBA rgb a}";

  palettes = { gruvbox = import ./palettes/gruvbox.nix { inherit rgb; }; };

  isRGBAttrs = expr: lib.isAttrs expr && lib.hasExactAttrs [ "r" "g" "b" ] expr;

  # Recurse deeply into attrs and lists, and transform each RGB attrs by `op`.
  transformPalette = op:
    lib.mapRecursiveCond (expr: !(isRGBAttrs expr))
    (_: expr: if isRGBAttrs expr then op expr else expr);
in {
  # FUNCTIONS #
  inherit rgb hexRGB hexRGB' hexRGBA hexRGBA';
  # COLORS #
  inherit palettes;
  formats = {
    # Pre-transform palettes by specified `op` functor.
    custom = op: transformPalette op palettes;

    # Each color attribute is a value according
    # to the format functor that produces it.
    hexRGB = transformPalette hexRGB palettes;
    hexRGB' = transformPalette hexRGB' palettes;

    # For palettes ending with `A`, each color attribute is a function
    # to which an alpha float value must be applied.
    hexRGBA = transformPalette hexRGBA palettes;
    hexRGBA' = transformPalette hexRGBA' palettes;
  };
}
