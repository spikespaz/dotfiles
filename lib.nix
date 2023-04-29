lib:
let
  _traceMsgVal = msg: val: ''
    ${msg}
    ${lib.generators.toPretty { multiline = true; } val}'';

  traceM = m: v: builtins.trace (_traceMsgVal m v);
  traceValM = m: v: builtins.trace (_traceMsgVal m v) v;

  # accept a list of attrs, update into one attrs
  updates = builtins.foldl' (a: b: a // b) { };

  mkDirEntry = dirname: basename: type: rec {
    inherit type;
    name = basename;
    path = "${dirname}/${basename}";

    isHidden = lib.hasPrefix "." name;
    isFile = type == "regular";
    isDir = type == "directory";
    isProject = !isHidden && (isFile || isDir);
    isNixFile = isFile && lib.hasSuffix ".nix" name;
    hasDefault = let ls = builtins.readDir "${path}";
    in ls ? "default.nix" && ls."default.nix" == "regular";
    hasNixFiles =
      let ls = lib.mapAttrsToList (mkDirEntry path) (builtins.readDir path);
      in builtins.any (it: it.isNixFile || (it.isDir && it.hasNixFiles)) ls;
    isNix = isProject && (isNixFile || (isDir && hasNixFiles));
  };

  mkFlakeTree = path:
    lib.pipe (builtins.readDir path) [
      (lib.mapAttrsToList (name: type:
        let it = mkDirEntry path name type;
        in if it.isNix then it else null))
      (builtins.filter (x: !(isNull x)))
      (map (it: {
        name =
          if it.isNixFile then lib.removeSuffix ".nix" it.name else it.name;
        value = if it.isNixFile then
          import it.path
          ## commented out to fallthrough, will expose
          ## `default.nix` as `default` attr
          # else if it.isDir && it.hasDefault then
          #   import it.path
        else if it.isDir && it.hasNixFiles then
          mkFlakeTree it.path
        else
          abort traceValM "unchecked direntry:" it;
      }))
      builtins.listToAttrs
    ];

  thruAttr = attr: it:
    if lib.isAttrs it && it ? ${attr} then it.${attr} else it;
  mapThruAttr = attr: lib.mapAttrs (name: thruAttr attr);
  # TODO cannot handle scoped packages
  mkUnfreeOverlay = pkgs: names:
    lib.pipe names [
      (map (name: {
        inherit name;
        value = pkgs.${name};
      }))
      builtins.listToAttrs
      (builtins.mapAttrs (_: package:
        package.overrideAttrs (old:
          lib.recursiveUpdate old {
            meta.license = (if builtins.isList old.meta.license then
              map (_: { free = true; }) old.meta.license
            else {
              free = true;
            });
          })))
    ];

  deepMergeAttrs = attrList:
    let
      recurse = attrPath:
        lib.zipAttrsWith (n: values:
          (if lib.tail values == [ ] then
            lib.head values
          else if lib.all lib.isList values then
            lib.unique (lib.concatLists values)
          else if lib.all lib.isAttrs values then
            recurse (attrPath ++ [ n ]) values
          else
            lib.last values));
    in recurse [ ] attrList;

  # logical implication,
  # compates c to falsy values, if falsy
  # use d otherwise evaluate v
  imply = c: v: implyDefault c null v;
  implyDefault = c: d: v:
    if (c == null) || c == false || c == { } || c == [ ] || c == "" || c
    == 0 then
      d
    else
      v;

  # find indices of item needle in list haystack
  indicesOf = _wrapSplitFn (needle: haystack:
    lib.pipe haystack [
      (lib.imap0 (i: v: { inherit i v; }))
      (builtins.filter (c: c.v == needle))
      (map (x: x.i))
    ]);

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
      idx = imply idxs ((builtins.head idxs) + 1);
      len = builtins.length haystack;
    in imply len {
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
      idx = imply idxs ((lib.last idxs) + 1);
      len = builtins.length haystack;
    in imply len {
      l = lib.sublist 0 (idx - 1) haystack;
      r = lib.sublist idx (len - 1) haystack;
    });

  # This is a bad solution
  toTOMLFile = pkgs: name: attrs:
    (pkgs.runCommandLocal "nix-to-toml_${name}" { } ''
      mkdir $out
      cat "${pkgs.writeText "nix-to-json-${name}" (builtins.toJSON attrs)}" \
        | ${lib.getExe pkgs.yj} -jt > "$out/${name}.toml"
    '').outPath + "/${name}.toml";
  toTOML = attrs: builtins.readFile (toTOMLFile "unknown" attrs);
in {
  inherit
  # Tracing
    traceM traceValM updates
    # Attribute Sets
    deepMergeAttrs thruAttr mapThruAttr
    # Boolean Logic
    imply implyDefault
    # List Comprehension
    indicesOf split lsplit rsplit
    # Flake Utilities
    mkFlakeTree mkUnfreeOverlay
    # Formats
    toTOMLFile toTOML;
}
