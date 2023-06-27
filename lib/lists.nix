{ lib }:
let
  # find indices of item needle in list haystack
  indicesOf = _wrapSplitFn (needle: haystack:
    lib.pipe haystack [
      (lib.imap0 (i: v: { inherit i v; }))
      (builtins.filter (c: c.v == needle))
      (map (x: x.i))
    ]);

  indexOf = default:
    _wrapSplitFn (x: xs:
      lib.pipe xs [
        (lib.imap0 (i: v: if v == x then i else null))
        (lib.findFirst (x: x != null) default)
      ]);

  # get element at n if present, null otherwise
  getElemAt = xs: n:
    if builtins.length xs > n then builtins.elemAt xs n else null;

  removeElems = xs: remove:
    lib.pipe xs [
      (lib.mapListToAttrs (x: lib.nameValuePair x null))
      (xs: removeAttrs xs remove)
      (builtins.listToAttrs)
    ];

  sublist = idx: j: l:
    let adv = j - idx;
    in lib.foldl' (l': i: l' ++ [ builtins.elemAt i l ]) [ ]
    (lib.range idx adv);

  # split a list-compatible haystack
  # at every occurrence and return
  # a list of slices between occurrences
  split = _wrapSplitFn (needle: haystack:
    let
      idxs = indicesOf needle haystack;
      idxs0 = [ 0 ] ++ map (x: x + 1) idxs;
      idxs1 = idxs ++ [ (builtins.length haystack) ];
      pairs = map ({ fst, snd, }: {
        i = fst;
        l = snd - fst;
      }) (lib.zipLists idxs0 idxs1);
    in map ({ i, l, }: lib.sublist i l haystack) pairs);

  # split a list-compatible haystack
  # at the leftmost occurrence of needle
  # returns attrs l and r, each being the respective
  # left or right side of the occurrence of needle
  lsplit = _wrapSplitFn (needle: haystack:
    let
      idxs = indicesOf needle haystack;
      idx = lib.imply idxs ((builtins.head idxs) + 1);
      len = builtins.length haystack;
    in lib.imply len {
      l = lib.sublist 0 (idx - 1) haystack;
      r = lib.sublist idx (len - 1) haystack;
    });

  # split a list-compatible haystack
  # at the rightmost occurrence of needle
  # returns attrs l and r, each being the respective
  # left or right side of the occurrence of needle
  rsplit = _wrapSplitFn (needle: haystack:
    let
      idxs = indicesOf needle haystack;
      idx = lib.imply idxs ((lib.last idxs) + 1);
      len = builtins.length haystack;
    in lib.imply len {
      l = lib.sublist 0 (idx - 1) haystack;
      r = lib.sublist idx (len - 1) haystack;
    });

  # wraps *split functions
  # to accept other types with a list reperesentation
  # currently only string
  _wrapSplitFn = fn: n: h:
    if lib.isString h then
      let v = fn n (lib.stringToCharacters h);
      in if lib.isAttrs v then
        builtins.mapAttrs (_: lib.concatStrings) v
      else
        map lib.concatStrings v
    else
      fn n h;
in {
  #
  inherit indicesOf indexOf getElemAt removeElems sublist split lsplit rsplit;
}
