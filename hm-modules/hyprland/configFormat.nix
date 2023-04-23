# This file copies the style of:
# <https://github.com/NixOS/nixpkgs/blob/55bf31e28e1b11574b56926d8c80f45271d696d5/pkgs/pkgs-lib/formats.nix>
{
  lib,
  pkgs,
  ...
}: configOpts: let
  configOpts' =
    {
      sortFn = lib.sort (_: _: false);
      indentChars = "    ";
    }
    // configOpts;

  toConfigString = opts: attrs:
    lib.pipe attrs [
      (mkConfigDocument [])
      (sortConfigDocument opts.sortFn)
      configDocumentToNestedLines
      (compileNestedLines opts.indentChars)
    ];

  mkPathNameValue = path: name: value: {
    inherit name value;
    path = path ++ [name];
  };

  mkConfigDocument = path: attrs: let
    # The first step is to break the attributes out into three
    # distinct sections, which each get special treatment.
    #
    # The first is for unique attribute names with distinct individual values.
    variables = lib.pipe attrs [
      (lib.filterAttrs (_: v: !(lib.isAttrs v || lib.isList v)))
      (lib.mapAttrsToList (mkPathNameValue path))
    ];
    # Repeats is for variables whose keys can occur multiple times.
    # Hyprland allows for a variable to have multiple values.
    # In Nix this is represented as an attribute with a list of values.
    repeats = lib.pipe attrs [
      (lib.filterAttrs (_: lib.isList))
      (lib.mapAttrsToList (name:
        map (value:
          mkPathNameValue path name value)))
      lib.concatLists
    ];
    # Lastly comes the sections, attributes of more config variables.
    sections = lib.pipe attrs [
      (lib.filterAttrs (_: lib.isAttrs))
      (lib.mapAttrsToList (name: value: {
        inherit name;
        path = path ++ [name];
        value = mkConfigDocument (path ++ [name]) value;
      }))
    ];
  in
    lib.concatLists [variables repeats sections];

  # Recursively sort lists of PathNameValue items.
  sortConfigDocument = sortFn: config:
    map (it:
      if lib.isList it.value
      then it // {value = sortConfigDocument sortFn it.value;}
      else it)
    (sortFn config);

  # Convert the
  configDocumentToNestedLines = map (it:
    if lib.isList it.value
    then ["${it.name} {" (configDocumentToNestedLines it.value) "}"]
    else "${it.name} = ${valueToString it.value}");

  # Creates a string with chars repeated N times.
  mkIndent = chars: level: lib.concatStrings (map (_: chars) (lib.range 1 level));

  # Writes a string line by line. Input is a list of lists and strings.
  # Each string at any nested level is a line. Nested level determines indentation.
  compileNestedLines = indentChars: lines: let
    recurse = level:
      lib.foldl' (buf: it:
        if lib.isList it
        then recurse (level + 1) buf it
        else buf + "\n" + (mkIndent indentChars level) + it);
  in
    recurse 0 "" lines;

  # Converts a single value to a valid Hyprland config RHS
  valueToString = value:
    if value == null
    then ""
    else if lib.isBool value
    then lib.boolToString value
    else if lib.isInt value || lib.isFloat value
    then toString value
    else if lib.isString value
    then value
    else if lib.isList value
    then lib.concatMapStringsSep " " valueToString value
    else abort (lib.traceSeqN 2 value "Invalid value, cannot convert '${builtins.typeOf value}' to Hyprland config string value");

  # Turn a recursive attrset into a list of
  # `{ path = [...]; value = ...; }` where `path` and `value` are analogous
  # to a name value pair.
  attrsToPathValueList = let
    recurse = path: attrs:
      lib.flatten (lib.mapAttrsToList (name: value:
        if lib.isAttrs value
        then (recurse (path ++ [name]) value)
        else {
          path = path ++ [name];
          inherit value;
        })
      attrs);
  in
    recurse [];

  # Inverse operation for `attrsToPathValueList`.
  pathValueListToAttrs = lib.foldl' (
    acc: attr:
      lib.recursiveUpdate acc (lib.setAttrByPath attr.path attr.value)
  ) {};

  # Takes a list of renames and attrs for the hyprland config,
  # and recursively renames attributes accordingly.
  renameAll = renames: attrs:
    lib.pipe attrs [
      # get a list of `{ path = [...]; value = ...; }`
      attrsToPathValueList
      # rename the `path` of the attrs who need to be renamed
      (map (attr: let
        spec = lib.findFirst (spec: attr.path == spec.prefer) null renames;
      in
        if spec == null
        then attr
        else {
          path = spec.original;
          inherit (attr) value;
        }))
      # back to one attrset
      pathValueListToAttrs
    ];
in {
  # freeformType = types.attrsOf types.anything;
  type = with lib.types; let
    valueType = oneOf [bool number singleLineStr attrsOfValueTypes listOfValueTypes];
    attrsOfValueTypes = attrsOf valueType;
    listOfValueTypes = listOf valueType;
  in
    attrsOfValueTypes;

  toConfigString = toConfigString configOpts';

  # generate = name: value: pkgs.writeText name (stringify value);

  # Would have been much nicer to use this, but it causes infrec.
  # imports = map (spec: lib.mkAliasOptionModule spec.prefer spec.original) renames;
}
