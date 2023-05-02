# This `default.nix` serves as an index of modules when imported.
args@{ tree, lib, ... }:
let modulesTree = tree.users.jacob.programs; # CHANGE ME
in lib.pipe modulesTree [
  (mt: removeAttrs mt [ "default" "toplevel" ])
  (lib.mapThruAttr "default")
  (mt: mt // modulesTree.toplevel args)
]
