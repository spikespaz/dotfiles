# This file should closely mirror `lists.nix`,
# with new string-specific definitions at the bottom of the file.
#
# Documentation comments are not considered necessary for functions
# which have a list-compatible counterpart.
#
# If you are looking for documentation for members undocumented here,
# see the appropriate counterpart from `lists.nix`.
{ lib }:
let
  # `lib.lists.indicesOf`
  indicesOfChar = char: str: lib.indicesOf char (lib.stringToCharacters str);

  # `lib.lists.indexOfDefault`
  indexOfCharDefault = default: char: str:
    lib.indexOfDefault default char (lib.stringToCharacters str);

  # `lib.lists.indexOf`
  indexOfChar = indexOfCharDefault null;

  # `lib.lists.lastIndexOfDefault`
  lastIndexOfCharDefault = default: char: str:
    lib.lastIndexOfDefault default char (lib.stringToCharacters str);

  # `lib.lists.lastIndexOf`
  lastIndexOfChar = lastIndexOfCharDefault null;

  # `lib.lists.elemAtDefault`
  charAtDefault = default: index: str:
    if index > 0 && index < builtins.stringLength str then
      builtins.substring index 1 str
    else
      default;

  # `lib.lists.elemAt`
  charAt = charAtDefault null;

  # The string equivalent of `lib.lists.removeElems`,
  # but `chars` (the ones to remove) can be
  # specified as either a list or a string.
  removeChars = chars:
    let
      chars' =
        if builtins.isString chars then lib.stringToCharacters chars else chars;
      replace = builtins.genList (_: "") (builtins.length chars');
    in builtins.replaceStrings chars' replace;

  # The string equivalent of `lib.lists.sublist`.
  # Note that this is different from the builtin.
  #
  # The `builtins.substring` function takes a start index and a length,
  # whereas this function takes a start index and an end index.
  substring = start: end: builtins.substring start (end - start);

  # `lib.lists.split`
  # The missing function `lib.strings.splitString` is provided by Nixpkgs.
  __stub.splitString = null;

  # `lib.lists.lsplit`
  lsplitString = char: str:
    with (lib.lsplit char (lib.stringToCharacters str)); {
      l = lib.concatStrings l;
      r = lib.concatStrings r;
    };

  # `lib.lists.rsplit`
  rsplitString = char: str:
    with (lib.rsplit char (lib.stringToCharacters str)); {
      l = lib.concatStrings l;
      r = lib.concatStrings r;
    };

  # The string equivalent of `lib.lists.lpad`.
  #
  # The argument `fillChar` must be a string containing at most
  # a single character; anything else is considered undefined behavior
  # (the resultant string will be longer than expected).
  # This is not checked in favor of keeping cycles down.
  #
  # This is similar to `lib.fixedWidthString` but the arguments
  # for the total desired string length and the character to fill with
  # are reversed.
  lpadString = fillChar: totalLen: str:
    let
      padLen = totalLen - (builtins.stringLength str);
      padChars = lib.replicate padLen fillChar;
    in lib.concatStrings (padChars ++ [ str ]);

  # The string equivalent of `lib.lists.rpad`.
  #
  # Same as `lpadString` but appends fill characters to the right
  # instead of the left.
  rpadString = fillChar: totalLen: str:
    let
      padLen = totalLen - (builtins.stringLength str);
      padChars = lib.replicate padLen fillChar;
    in lib.concatStrings ([ str ] ++ padChars);
in {
  #
  inherit indicesOfChar indexOfCharDefault indexOfChar lastIndexOfCharDefault
    lastIndexOfChar charAtDefault charAt removeChars substring lsplitString
    rsplitString lpadString rpadString;
}