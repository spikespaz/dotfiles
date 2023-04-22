# This file copies the style of:
# <https://github.com/NixOS/nixpkgs/blob/55bf31e28e1b11574b56926d8c80f45271d696d5/pkgs/pkgs-lib/formats.nix>
{
  lib,
  pkgs,
  ...
}: {
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
in rec {
  # freeformType = types.attrsOf types.anything;
  type = with types; let
    valueType = oneOf [bool number singleLineStr attrsOfValueTypes listOfValueTypes];
    attrsOfValueTypes = attrsOf valueType;
    listOfValueTypes = listOf valueType;
  in
    attrsOfValueTypes;

  stringify = value: configToString value;
  generate = name: value: pkgs.writeText name (stringify value);

  # Would have been much nicer to use this, but it causes infrec.
  # imports = map (spec: lib.mkAliasOptionModule spec.prefer spec.original) renames;
}
