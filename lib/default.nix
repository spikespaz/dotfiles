final: prev:
let
  callLibs = file: import file { lib = final; };
  lib = {
    attrsets = callLibs ./attrsets.nix;
    builders = callLibs ./builders.nix;
    debug = callLibs ./debug.nix;
    # generators = callLibs ./generators.nix;
    lists = callLibs ./lists.nix;
    strings = { inherit (lib.lists) indicesOf split lsplit rsplit; };
    shellscript = callLibs ./shellscript.nix;
    trivial = callLibs ./trivial.nix;
  };
  prelude = {
    inherit (lib.attrsets)
      updates recursiveUpdates deepMergeAttrs thruAttr mapThruAttr;
    inherit (lib.debug) traceM traceValM;
    inherit (lib.lists)
      indicesOf getElemAt removeElems sublist split lsplit rsplit;
    inherit (lib.shellscript) writeShellScriptShebang writeNuScript;
    inherit (lib.trivial) imply implyDefault applyArgs;
  };
in prev // prelude // {
  birdos = {
    inherit prelude;
    inherit (lib.builders) mkFlakeTree mkFlakeSystems mkHost mkHome;
  };
}
