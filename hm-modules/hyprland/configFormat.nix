# This file copies the style of:
# <https://github.com/NixOS/nixpkgs/blob/55bf31e28e1b11574b56926d8c80f45271d696d5/pkgs/pkgs-lib/formats.nix>
{
  lib,
  pkgs,
  ...
}: {
  renames,
  indentChars ? "    ",
}: let
  inherit (lib) types;

  # Creates a string with chars repeated N times.
  mkIndent = chars: level: lib.concatStrings (map (_: chars) (lib.range 1 level));

  # Writes a string line by line. Input is a list of lists and strings.
  # Each string at any nested level is a line. Nested level determines indentation.
  writeIndented = chars: lines: let
    recurse = level:
      lib.foldl' (buf: it:
        if lib.isList it
        then recurse (level + 1) buf it
        else buf + "\n" + (mkIndent chars level) + it);
  in
    recurse 0 "" lines;

  concatListsSep = sep: lib.foldl' (acc: it: acc ++ [sep] ++ it) [];

  # Takes an attrset and writes out a Hyprland config.
  configToString = attrs: let
    recurse = level: attrs: let
      variables = lib.filterAttrs (_: v: !(lib.isAttrs v || lib.isList v)) attrs;
      repeats = lib.filterAttrs (_: lib.isList) attrs;
      sections = lib.filterAttrs (_: lib.isAttrs) attrs;
    in
      lib.concatLists [
        # Variables
        (lib.mapAttrsToList (
            name: value: "${name} = ${valueToString value}"
          )
          variables)
        # Repeats
        (concatListsSep "" (lib.mapAttrsToList (
            name: value: (map (value: "${name} = ${valueToString value}") value)
          )
          repeats))
        # Sections
        (concatListsSep "" (lib.mapAttrsToList (
            name: value: ["${name} {" (recurse (level + 1) value) "}"]
          )
          sections))
      ];
  in
    writeIndented indentChars (recurse 0 attrs);

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
in rec {
  # freeformType = types.attrsOf types.anything;
  type = with types; let
    valueType = oneOf [bool number singleLineStr attrsOfValueTypes listOfValueTypes];
    attrsOfValueTypes = attrsOf valueType;
    listOfValueTypes = listOf valueType;
  in
    attrsOfValueTypes;

  stringify = value: configToString (renameAll renames value);
  generate = name: value: pkgs.writeText name (stringify value);

  # Would have been much nicer to use this, but it causes infrec.
  # imports = map (spec: lib.mkAliasOptionModule spec.prefer spec.original) renames;
}
