{ lib }:
let
  # find indices of item needle in list haystack
  indicesOf = needle: haystack:
    lib.pipe haystack [
      (lib.imap0 (i: v: { inherit i v; }))
      (builtins.filter (c: c.v == needle))
      (map (x: x.i))
    ];

  indexOf = default: needle: haystack:
    lib.pipe haystack [
      (lib.imap0 (i: v: if v == needle then i else null))
      (lib.findFirst (x: x != null) default)
    ];

  # get element at n if present, null otherwise
  getElemAt = xs: n:
    if builtins.length xs > n then builtins.elemAt xs n else null;

  removeElems = xs: remove:
    lib.pipe xs [
      (lib.mapListToAttrs (x: lib.nameValuePair x null))
      (xs: removeAttrs xs remove)
      (builtins.listToAttrs)
    ];

  # Takes a starting index and an ending index and returns
  # a new list with the items between that range from `list`.
  # The result is not inclusive of the item at `end`.
  sublist = start: end: list:
    lib.foldl' (acc: i: acc ++ [ (builtins.elemAt list i) ]) [ ]
    (lib.range start (end - 1));

  # split a list-compatible haystack
  # at every occurrence and return
  # a list of slices between occurrences
  split = needle: haystack:
    let
      idxs = indicesOf needle haystack;
      idxs0 = [ 0 ] ++ map (x: x + 1) idxs;
      idxs1 = idxs ++ [ (builtins.length haystack) ];
      pairs = map ({ fst, snd, }: {
        i = fst;
        l = snd - fst;
      }) (lib.zipLists idxs0 idxs1);
    in map ({ i, l, }: lib.sublist i l haystack) pairs;

  # split a list-compatible haystack
  # at the leftmost occurrence of needle
  # returns attrs l and r, each being the respective
  # left or right side of the occurrence of needle
  lsplit = needle: haystack:
    let
      idxs = indicesOf needle haystack;
      idx = lib.imply idxs ((builtins.head idxs) + 1);
      len = builtins.length haystack;
    in lib.imply len {
      l = lib.sublist 0 (idx - 1) haystack;
      r = lib.sublist idx (len - 1) haystack;
    };

  # split a list-compatible haystack
  # at the rightmost occurrence of needle
  # returns attrs l and r, each being the respective
  # left or right side of the occurrence of needle
  rsplit = needle: haystack:
    let
      idxs = indicesOf needle haystack;
      idx = lib.imply idxs ((lib.last idxs) + 1);
      len = builtins.length haystack;
    in lib.imply len {
      l = lib.sublist 0 (idx - 1) haystack;
      r = lib.sublist idx (len - 1) haystack;
    };
in {
  #
  inherit indicesOf indexOf getElemAt removeElems sublist split lsplit rsplit;
}
