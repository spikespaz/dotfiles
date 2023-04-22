# This file copies the style of:
# <https://github.com/NixOS/nixpkgs/blob/55bf31e28e1b11574b56926d8c80f45271d696d5/pkgs/pkgs-lib/formats.nix>
{
  lib,
  pkgs,
  ...
}: {
  renames,
  indent ? "    ",
}: let
  inherit (lib) types;

  # Creates a string with chars repeated N times.
  indentChars = chars: level: lib.concatStrings (map (_: chars) (lib.range 1 level));
  indentChars' = indentChars indent;

  # Takes an attrset and writes out a Hyprland config.
  configToString = let
    recurse = level: attrs: let
      lines = lib.filterAttrs (_: v: !(lib.isAttrs v)) attrs;
      sections = lib.filterAttrs (_: lib.isAttrs) attrs;
    in
      lib.concatStrings (
        # Top level config attributes
        (lib.mapAttrsToList (
            name: value: "\n${indentChars' level}${name} = ${valueToString value}"
          )
          lines)
        # Then the sections
        ++ (lib.mapAttrsToList (
            name: value: "\n${indentChars' level}${name} {${recurse (level + 1) value}\n${indentChars' level}}"
          )
          sections)
      );
  in
    recurse 0;

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
