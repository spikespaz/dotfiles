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
  # __stub.splitString = null;

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

  # Removes the `pattern` string from the beginning and the end
  # of `str` as many times as it appears on either side.
  strip = pattern: str: rstrip pattern (lstrip pattern str);

  # Removes the `pattern` string from the beginning
  # of `str` as many times as it appears.
  lstrip = pattern: str:
    let
      strLen = builtins.stringLength str;
      patLen = builtins.stringLength pattern;
      starts = pattern == builtins.substring 0 patLen str;
    in if strLen >= patLen && starts then
      lstrip pattern (builtins.substring patLen strLen str)
    else
      str;

  # Removes the `pattern` string from the end
  # of `str` as many times as it appears.
  rstrip = pattern: str:
    let
      strLen = builtins.stringLength str;
      patLen = builtins.stringLength pattern;
      ends = pattern == builtins.substring (strLen - patLen) patLen str;
    in if strLen >= patLen && ends then
      rstrip pattern (builtins.substring 0 (strLen - patLen) str)
    else
      str;

  # Removes whitespace from the beginning and end of a string.
  #
  # This function is expensive, because it recurses deeply with several loops.
  # This could be improved by re-implementing `rstrip` and `lstrip` to
  # operate with a list of patterns instead of a single pattern string.
  trim = str:
    let
      # Not two spaces, the second is a tab character.
      white = [ " " "	" "\n" "\r" ];
      stripped = lib.pipe str (map strip white);
    in if stripped == str then str else trim stripped;

  # Checks if second argument `str` begins with the `pattern` string.
  startsWith = pattern: str:
    let
      strLen = builtins.stringLength str;
      patLen = builtins.stringLength pattern;
    in if strLen >= patLen then
      pattern == builtins.substring 0 patLen str
    else
      false;

  # Checks if second argument `str` ends with the `pattern` string.
  endsWith = pattern: str:
    let
      strLen = builtins.stringLength str;
      patLen = builtins.stringLength pattern;
    in if strLen >= patLen then
      pattern == builtins.substring (strLen - patLen) patLen str
    else
      false;
in {
  #
  inherit indicesOfChar indexOfCharDefault indexOfChar lastIndexOfCharDefault
    lastIndexOfChar charAtDefault charAt removeChars substring lsplitString
    rsplitString lpadString rpadString strip lstrip rstrip trim startsWith
    endsWith;
}
