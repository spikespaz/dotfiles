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
      spaceAroundEquals = true;
    }
    // configOpts;

  toConfigString = {
    sortPred,
    indentChars,
    spaceAroundEquals,
  }: attrs:
    lib.pipe attrs [
      (attrsToNodeList [])
      (recursiveSortNodeList sortPred)
      (renderNodeList {
        inherit indentChars spaceAroundEquals;
      })
    ];

  isNodeType = type: node: node._node_type == type;
  mkNodeType = type: path: name: value: {
    _node_type = type;
    inherit name value;
    path = path ++ [name];
  };

  isStringNode = isNodeType "string";
  isIndentNode = isNodeType "indent";
  isVariableNode = isNodeType "variable";
  isRepeatNode = isNodeType "repeatBlock";
  isSectionNode = isNodeType "configDocument";

  mkStringNode = mkNodeType "string";
  mkIndentNode = mkNodeType "indent";
  mkVariableNode = mkNodeType "variable";
  mkRepeatNode = mkNodeType "repeatBlock";
  mkSectionNode = mkNodeType "configDocument";

  # concatListsSep = sep: lib.foldl' (a: b: a ++ [sep] ++ b) [];

  attrsToNodeList = path: attrs: let
    variables = lib.pipe attrs [
      (lib.filterAttrs (_: v: !(lib.isAttrs v || lib.isList v)))
      (lib.mapAttrsToList (mkVariableNode path))
    ];
    repeats = lib.pipe attrs [
      (lib.filterAttrs (_: lib.isList))
      (lib.mapAttrsToList (name: values:
        mkRepeatNode path name (
          map (value: mkVariableNode path name value) values
        )))
    ];
    sections = lib.pipe attrs [
      (lib.filterAttrs (_: lib.isAttrs))
      (lib.mapAttrsToList (name: value:
          mkSectionNode path name (attrsToNodeList (path ++ [name]) value)))
    ];
  in
    lib.concatLists [variables repeats sections];

  recursiveSortNodeList = sortPred: l:
    lib.pipe l [
      (map (node:
        if isSectionNode node
        then node // {value = recursiveSortNodeList sortPred node.value;}
        else node))
      (lib.sort (a: b: sortPred a.path b.path))
    ];

  # Creates a string with chars repeated N times.
  repeatChars = chars: level: lib.concatStrings (map (_: chars) (lib.range 1 level));

  renderNode = opts @ {
    indentChars,
    spaceAroundEquals,
  }: node:
    if isStringNode node
    then node.value
    else if isIndentNode node
    then repeatChars indentChars node.value
    else if isVariableNode node
    then let
      equals =
        if spaceAroundEquals
        then " = "
        else "=";
    in "${node.name}${equals}${valueToString node.value}\n"
    else if isRepeatNode node
    then lib.concatStrings (map (renderNode opts) node.value)
    else if isSectionNode node
    then "${node.name} {\n${renderNodeList opts node.value}}\n"
    else abort "Not a valid node";

  renderNodeList = opts: l: lib.concatStrings (map (renderNode opts) l);

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
