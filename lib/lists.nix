{ lib }:
let
  # Return a list of indices where element needle
  # occurs in list haystack.
  indicesOf = needle: haystack:
    lib.pipe haystack [
      (lib.imap0 (i: v: { inherit i v; }))
      (builtins.filter (c: c.v == needle))
      (map (x: x.i))
    ];

  # Return the index of the first occurrence of element needle
  # found in the list haystack.
  #
  # If element needle is not found in list, return default.
  indexOfDefault = default: needle: haystack:
    let
      idx = lib.foldl'
        (i: el: if i < 0 then if el == needle then -i - 1 else i - 1 else i)
        (-1) haystack;
    in if idx < 0 then default else idx;

  # Same as `indexOfDefault` but using `null` as the default.
  indexOf = indexOfDefault null;

  # Same as `indexOfDefault` but returns the index of the last occurrence
  # of element needle rather than the first.
  #
  # This function is more expensive than `indexOfDefault`.
  lastIndexOfDefault = default: needle: haystack:
    let indices = indicesOf needle haystack;
    in if indices == [ ] then default else lib.last indices;

  # Same as `lastIndexOfDefault` but using `null` as the default.
  lastIndexOf = lastIndexOfDefault null;

  # Same as `builtins.elemAt` but takes a default value as the first argument,
  # which will be returned if the index is invalid.
  #
  # This assumes that the index is an integer.
  elemAtDefault = default: list: index:
    if index > 0 && index < builtins.length list then
      builtins.elemAt list index
    else
      default;

  # Removes every occurrence of each element from the list provided as
  # the second argument.
  removeElems = elems: builtins.filter (el: indexOf el elems == null);

  # Takes a starting index and an ending index and returns
  # a new list with the items between that range from `list`.
  # The result is not inclusive of the item at `end`.
  sublist = start: end: list:
    lib.foldl' (acc: i: acc ++ [ (builtins.elemAt list i) ]) [ ]
    (lib.range start (end - 1));

  # Split a list haystack at every occurrence of element needle,
  # returning a list of lists where every inner list is section
  # of haystack.
  split = needle: haystack:
    let
      idxs = indicesOf needle haystack;
      idxs0 = [ 0 ] ++ idxs;
      idxs1 = idxs ++ [ (builtins.length haystack) ];
      idxPairs = lib.zipLists idxs0 idxs1;
    in map ({ fst, snd }: sublist (fst + 1) snd haystack) idxPairs;

  # Split a list haystack into separate left and right lists
  # at the position of the first occurrence of element needle.
  #
  # Returns an attribute set with left and right lists as
  # names `r` and `l` respectively.
  #
  # If element needle is not in list, return `null`.
  lsplit = needle: haystack:
    let
      idx = indexOf needle haystack;
      len = builtins.length haystack;
    in if idx == null then
      null
    else {
      l = sublist 0 idx haystack;
      r = sublist (idx + 1) len haystack;
    };

  # Same as `lsplit` but splits at the last occurrence
  # of element needle rather than the first.
  rsplit = needle: haystack:
    let
      idx = lastIndexOf needle haystack;
      len = builtins.length haystack;
    in if idx == null then
      null
    else {
      l = sublist 0 idx haystack;
      r = sublist (idx + 1) len haystack;
    };
in {
  #
  inherit indicesOf indexOfDefault indexOf lastIndexOfDefault lastIndexOf
    elemAtDefault removeElems sublist split lsplit rsplit;
}
