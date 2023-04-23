# This file copies the style of:
# <https://github.com/NixOS/nixpkgs/blob/55bf31e28e1b11574b56926d8c80f45271d696d5/pkgs/pkgs-lib/formats.nix>
{
  lib,
  pkgs,
  ...
}: configOpts: let
  configOpts' =
    {
      sortPred = _: _: false;
      indentChars = "    ";
    }
    // configOpts;

  toConfigString = {
    sortPred,
    indentChars,
  }: attrs:
    lib.pipe attrs [
      (mkConfigDocument [])
      (sortConfigDocument sortPred)
      configDocumentToNestedLines
      (compileNestedLines indentChars)
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
  sortConfigDocument = sortPred: config:
    map (it:
      if lib.isList it.value
      then it // {value = sortConfigDocument sortPred it.value;}
      else it)
    (lib.sort (a: b: sortPred a.path b.path) config);

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
in {
  # freeformType = types.attrsOf types.anything;
  type = with lib.types; let
    valueType = oneOf [bool number singleLineStr attrsOfValueTypes listOfValueTypes];
    attrsOfValueTypes = attrsOf valueType;
    listOfValueTypes = listOf valueType;
  in
    attrsOfValueTypes;

  toConfigString = toConfigString configOpts';
  generate = name: value: pkgs.writeText name (toConfigString configOpts' value);
}
