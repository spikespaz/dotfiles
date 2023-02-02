{
  lib,
  pkgs,
  ...
}: let
  _traceMsgVal = msg: val: "${msg}\n${lib.generators.toPretty {multiline = true;} val}";

  traceM = m: v: builtins.trace (_traceMsgVal m v);
  traceValM = m: v: builtins.trace (_traceMsgVal m v) v;

  # accept a list of attrs, update into one attrs
  updates = builtins.foldl' (a: b: a // b) {};

  # rename attributes whose name is default,
  # if no default exists the attrs will be untouched
  # if there is a default and no attr matching newName,
  # the default attr will be renamed to newName
  # if there is a default and an arrt matching newName,
  # the default attr will be renamed to ${newName}_default
  # and default will be renamed to newName
  _renameDefaultAttr = prefix: attrs: (
    lib.mapAttrs' (name: value: {
      name =
        if name == "default"
        then
          if attrs ? ${prefix}
          then "${prefix}_default"
          else prefix
        else name;
      inherit value;
    })
    attrs
  );

  # flatten and join inputs by attrPath,
  # which is a list of attr names used as accessors
  # any attrs named default in the value of the attr which is accessed
  # using the last elem in attrPath will be renamed
  # to the value of the previous segment
  # it is recommended to filter the inputs
  # beforehand to ensure that any malformed values are ignored,
  # if applicable
  _joinAttrFromInputs = attrPath: inputs:
    lib.pipe inputs [
      (builtins.mapAttrs (_: lib.getAttrFromPath attrPath))
      (builtins.mapAttrs _renameDefaultAttr)
      builtins.attrValues
      updates
    ];

  # with a list of inputs, for each that has nixosModules
  # collect the name and value of each module into one attrs
  joinNixosModules = flakes:
    lib.pipe flakes [
      (lib.filterAttrs (_: attrs: attrs ? nixosModules))
      (_joinAttrFromInputs ["nixosModules"])
    ];

  joinHomeModules = flakes:
    lib.pipe flakes [
      (lib.filterAttrs (_: attrs: attrs ? homeManagerModules))
      (_joinAttrFromInputs ["homeManagerModules"])
    ];

  # TODO cannot handle scoped packages
  mkUnfreeOverlay = pkgs: names:
    lib.pipe names [
      (map (name: {
        inherit name;
        value = pkgs.${name};
      }))
      builtins.listToAttrs
      (builtins.mapAttrs (_: package:
        package.overrideAttrs (
          old:
            lib.recursiveUpdate old {
              meta.license = (
                if builtins.isList old.meta.license
                then map (_: {free = true;}) old.meta.license
                else {free = true;}
              );
            }
        )))
    ];

  mergeAttrs = attrList: (
    let
      recurse = attrPath:
        lib.zipAttrsWith (n: values: (
          if lib.tail values == []
          then lib.head values
          else if lib.all lib.isList values
          then lib.unique (lib.concatLists values)
          else if lib.all lib.isAttrs values
          then recurse (attrPath ++ [n]) values
          else lib.last values
        ));
    in
      recurse [] attrList
  );

  # logical implication,
  # compates c to falsy values, if falsy
  # use d otherwise evaluate v
  imply = c: v: implyDefault c null v;
  implyDefault = c: d: v:
    if
      (c == null)
      || c == false
      || c == {}
      || c == []
      || c == ""
      || c == 0
    then d
    else v;

  # find indices of item needle in list haystack
  indicesOf = _wrapSplitFn (
    needle: haystack:
      lib.pipe haystack [
        (lib.imap0 (i: v: {inherit i v;}))
        (builtins.filter (c: c.v == needle))
        (map (x: x.i))
      ]
  );

  # wraps *split functions
  # to accept other types with a list reperesentation
  # currently only string
  _wrapSplitFn = fn: n: h:
    if lib.isString h
    then let
      v = fn n (lib.stringToCharacters h);
    in
      if lib.isAttrs v
      then builtins.mapAttrs (_: lib.concatStrings) v
      else map lib.concatStrings v
    else fn n h;

  # split a list-compatible haystack
  # at every occurrence and return
  # a list of slices between occurrences
  split = _wrapSplitFn (
    needle: haystack: let
      idxs = indicesOf needle haystack;
      idxs0 = [0] ++ map (x: x + 1) idxs;
      idxs1 = idxs ++ [(builtins.length haystack)];
      pairs = map ({
        fst,
        snd,
      }: {
        i = fst;
        l = snd - fst;
      }) (lib.zipLists idxs0 idxs1);
    in
      map ({
        i,
        l,
      }:
        lib.sublist i l haystack)
      pairs
  );

  # split a list-compatible haystack
  # at the leftmost occurrence of needle
  # returns attrs l and r, each being the respective
  # left or right side of the occurrence of needle
  lsplit = _wrapSplitFn (
    needle: haystack: let
      idxs = indicesOf needle haystack;
      idx = imply idxs ((builtins.head idxs) + 1);
      len = builtins.length haystack;
    in
      imply len {
        l = lib.sublist 0 (idx - 1) haystack;
        r = lib.sublist idx (len - 1) haystack;
      }
  );

  # split a list-compatible haystack
  # at the rightmost occurrence of needle
  # returns attrs l and r, each being the respective
  # left or right side of the occurrence of needle
  rsplit = _wrapSplitFn (needle: haystack: let
    idxs = indicesOf needle haystack;
    idx = imply idxs ((lib.last idxs) + 1);
    len = builtins.length haystack;
  in
    imply len {
      l = lib.sublist 0 (idx - 1) haystack;
      r = lib.sublist idx (len - 1) haystack;
    });

  # alternates to lib fns that don't trigger unauthorized
  # assumes path exists
  _pathType = path: _pathType' (dirOf path) (baseNameOf path);
  _pathType' = d: n: let
    ls = builtins.readDir d;
  in
    imply (ls ? ${n}) ls.${n};

  # do not use on flake root,
  # not allowed because pathIs* uses readDir ..
  _isImportable = path: let
    # file or directory?
    isDir = (_pathType path) == "directory";
    isFile = !isDir && (_pathType path) == "regular";
    # is a *.nix file?
    isNix = isFile && lib.hasSuffix ".nix" path;
    # is file named default.nix?
    isDefault = isFile && lib.hasSuffix "default.nix" path;
    # is dir with file named default.nix?
    hasDefault = isDir && ((_pathType "${path}/default.nix") == "regular");
  in
    (isDir && hasDefault) || (isNix && !isDefault);

  _getIndexAttrName = path: fName: type: let
    # file or directory?
    isDir = type == "directory";
    isFile = !isDir && type == "regular";
    # is a *.nix file?
    isNix = isFile && lib.hasSuffix ".nix" fName;
    # is file named default.nix?
    isDefault = isFile && fName == "default.nix";
    # is dir with file named default.nix?

    # hasDefault = isDir && (lib.pathIsRegularFile "${path}/${fName}/default.nix");
    hasDefault = isDir && (_pathType' "${path}/${fName}" "default.nix") == "regular";

    # is a valid candidate for being a module
    isValid = (isNix && !isDefault) || hasDefault;
  in
    imply isValid (
      if hasDefault
      then fName
      else if isNix
      then (rsplit "." fName).l
      else assert (lib.assertMsg false "unreachable code"); null
    );

  evalIndices = {
    pass ? {},
    expr,
    isRoot ? false,
  }: let
    # provide a default mkModuleIndex
    pass' = {inherit mkModuleIndex;} // pass;
  in
    # a basic attrset (the last recursion)
    if lib.isAttrs expr
    then
      lib.mapAttrsRecursive
      (_: expr:
        evalIndices {
          inherit expr;
          pass = pass';
        })
      expr
    # is a path literal or string, import and recurse
    else if
      builtins.isPath expr
      && (isRoot || _isImportable expr)
    then
      evalIndices {
        pass = pass';
        expr = import expr;
      }
    # is a function whose arguments match pass
    # eval if it can be, otherwise defer to the module system
    else if
      lib.isFunction expr
      && (
        let
          args = builtins.attrNames (builtins.functionArgs expr);
        in
          (args != [])
          && builtins.all (x: pass' ? ${x}) args
      )
    then expr pass'
    else expr;

  mkModuleIndex = {
    path,
    ignore ? [],
    include ? {},
  }: pass:
    lib.pipe (builtins.readDir path) [
      # remove file names from ignore list
      (ls: removeAttrs ls ignore)
      # (traceValM "IGNORES REMOVED\n${path}")
      # map name and type to canonical name and path
      (lib.mapAttrsToList (fName: fType: let
        name = _getIndexAttrName path fName fType;
      in
        imply name {
          inherit name;
          fPath = "${path}/${fName}";
        }))
      # remove nulls if entries failed name check
      (builtins.filter (x: x != null))
      # (traceValM "CANONICAL NAMES\n${path}")
      (map ({
        name,
        fPath,
      }: {
        inherit name;
        value = import fPath;
      }))
      # convert back to attrs from list of n v
      (builtins.listToAttrs)
      # (traceValM "BACK TO ATTRS\n${path}")
      # merge any provided includes
      (index: mergeAttrs [index include])
      # (traceValM "MERGED INCLUDES\n${path}")
      # evaluate recursively
      (expr: evalIndices {inherit pass expr;})
      # (traceValM "EVALUATED\n${path}")
    ];

  # This is a bad solution
  toTOMLFile = name: attrs:
    (pkgs.runCommandLocal "nix-to-toml_${name}" {} ''
      mkdir $out
      cat "${pkgs.writeText "nix-to-json-${name}" (builtins.toJSON attrs)}" \
        | ${lib.getExe pkgs.yj} -jt > "$out/${name}.toml"
    '')
    .outPath
    + "/${name}.toml";
  toTOML = attrs: builtins.readFile (toTOMLFile "unknown" attrs);
in {
  inherit
    traceM
    traceValM
    updates
    joinNixosModules
    joinHomeModules
    mkUnfreeOverlay
    mergeAttrs
    imply
    implyDefault
    indicesOf
    split
    lsplit
    rsplit
    evalIndices
    mkModuleIndex
    toTOMLFile
    toTOML
    ;
}
# TODO broken because of IFD
# <https://discord.com/channels/568306982717751326/741347063077535874/1036275439297122435>
# TODO missing builtin
# file or directory?
#   _iNodeType = path:
#     let t = builtins.readFile (
#       pkgs.runCommand "_iNodeType" {} ''
#         if [ -L '${path}' ] && [ -d '${path}' ]
#         then printf 'link-file' > $out
#         elif [ -L '${path}' ] && [ -f '${path}' ]
#         then printf 'link-dir' > $out
#         elif [ -d '${path}' ]
#         then printf 'dir' > $out
#         elif [ -f '${path}' ]
#         then printf 'file' > $out
#         else printf 'null' > $out
#         fi
#       '');
#     in if t == "null" then null else t;
#
#   _isImportable = path:
#     let
#       type = _iNodeType path;
#       # file or directory?
#       isDir = type == "dir" || type == "link-dir";
#       isFile = !isDir && type == "file" || type == "link-file";
#       # is a *.nix file?
#       isNix = isFile && lib.hasSuffix ".nix" path;
#       # is file named default.nix?
#       isDefault = isFile && lib.hasSuffix "default.nix" path;
#       # is dir with file named default.nix?
#       hasDefault = isDir && (
#         let t = _iNodeType "${path}/default.nix";
#         in t == "file" || t == "link-file");
#     in
#       (isDir && hasDefault) || (isNix && !isDefault);
#
# TODO this is not as robust as the disabled code above could be
#   _isImportable = path:
#     let
#       isDirWithDefault = lib.pathIsRegularFile "${path}/default.nix";
#       isNix = lib.hasSuffix ".nix" path;
#       isDefault = isNix && lib.hasSuffix "default.nix" path;
#     in
#       isDirWithDefault || (isNix && !isDefault);

