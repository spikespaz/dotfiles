{ lib }:
let
  # Return a list of indices where element `needle`
  # occurs in list `haystack`.
  indicesOf = needle: haystack:
    lib.pipe haystack [
      (lib.imap0 (i: v: { inherit i v; }))
      (builtins.filter (c: c.v == needle))
      (map (x: x.i))
    ];

  # Return the index of the first occurrence of element `needle`
  # found in the list `haystack`.
  #
  # If element needle is not found in list, return `default`.
  indexOfDefault = default: needle: haystack:
    let
      idx = lib.foldl'
        (i: el: if i < 0 then if el == needle then -i - 1 else i - 1 else i)
        (-1) haystack;
    in if idx < 0 then default else idx;

  # Same as `indexOfDefault` but using `null` as the default.
  indexOf = indexOfDefault null;

  # Same as `indexOfDefault` but returns the index of the last occurrence
  # of element `needle` rather than the first.
  #
  # This function is more expensive than `indexOfDefault`.
  lastIndexOfDefault = default: needle: haystack:
    let indices = indicesOf needle haystack;
    in if indices == [ ] then default else lib.last indices;

  # Same as `lastIndexOfDefault` but using `null` as the default.
  lastIndexOf = lastIndexOfDefault null;

  # Same as `builtins.elemAt` but with the `index` and `list`
  # arguments reversed, and the first argument is `default`
  # which will be returned if the index is invalid.
  #
  # This assumes that the index is an integer.
  elemAtDefault = default: index: list:
    if index > 0 && index < builtins.length list then
      builtins.elemAt list index
    else
      default;

  # Same as `elemAtDefault` but using `null` as the default.
  #
  # Note that this is not the same as `builtins.elemAt`.
  # The builtin function will halt if the index is out of bounds,
  # whereas this is a bounds-checked alternative.
  elemAt = elemAtDefault null;

  # Given a list of elements `elems` and a list to operate on,
  # remove each occurrence of every element in `elems` from the
  # provided list.
  removeElems = elems: builtins.filter (el: indexOf el elems == null);

  # Takes a `start` index and an `end` index and returns
  # a new list with the items between that range from `list`.
  #
  # The result is exclusive of the item at `end`.
  sublist = start: end: list:
    lib.foldl' (acc: i: acc ++ [ (builtins.elemAt list i) ]) [ ]
    (lib.range start (end - 1));

  # Split a list `haystack` at every occurrence of element `needle`,
  # returning a list of lists where every inner list is section
  # of haystack between the needles, not inclusive.
  split = needle: haystack:
    let
      idxs = indicesOf needle haystack;
      idxs0 = [ 0 ] ++ idxs;
      idxs1 = idxs ++ [ (builtins.length haystack) ];
      idxPairs = lib.zipLists idxs0 idxs1;
    in map ({ fst, snd }: sublist (fst + 1) snd haystack) idxPairs;

  # Split a list `haystack` into separate left and right lists
  # at the position of the first occurrence of element `needle`.
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

  # Given a value `fillElem`, a desired length `totalLen`, and a `list`,
  # return a fixed-width list prepended with `fillElem` as many times
  # as necessary to satisfy `totalLen`.
  lpad = fillElem: totalLen: list:
    let
      padLen = totalLen - (builtins.length list);
      padElems = lib.replicate padLen fillElem;
    in padElems ++ list;

  # Same as `lpad` but appends the fill elements to the list
  # rather than prepending.
  rpad = fillElem: totalLen: list:
    let
      padLen = totalLen - (builtins.length list);
      padElems = lib.replicate padLen fillElem;
    in list ++ padElems;

  # Like `lib.flatten`, but it takes an additional predicate function that
  # tells it whether to recurse into a list.
  #
  # The predicate function receives every list item at every recursion
  # as an argument, and must return `true` if that list is to also be flattened.
  #
  # This is very similar to `lib.mapAttrsRecursiveCond`.
  flattenCond = cond: x:
    if lib.isList x && cond x then
      lib.concatMap (y: flattenCond cond y) x
    else
      [ x ];
in {
  #
  inherit indicesOf indexOfDefault indexOf lastIndexOfDefault lastIndexOf
    elemAtDefault elemAt removeElems sublist split lsplit rsplit lpad rpad
    flattenCond;
}
