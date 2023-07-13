final: prev:
let
  callLibs = file: import file { lib = final; };

  lib = {
    attrsets = callLibs ./attrsets.nix;
    builders = callLibs ./builders.nix;
    debug = callLibs ./debug.nix;
    # generators = callLibs ./generators.nix;
    lists = callLibs ./lists.nix;
    math = callLibs ./math.nix;
    radix = callLibs ./radix.nix;
    strings = { inherit (lib.lists) indicesOf split lsplit rsplit; };
    shellscript = callLibs ./shellscript.nix;
    trivial = callLibs ./trivial.nix;
    units = callLibs ./units.nix;
    colors = callLibs ./colors;
  };

  prelude = {
    inherit (lib.attrsets)
      updates recursiveUpdates deepMergeAttrs thruAttr mapThruAttr
      mapListToAttrs;
    inherit (lib.debug) traceM traceValM;
    inherit (lib.lists)
      indicesOf indexOfDefault indexOf lastIndexOfDefault lastIndexOf
      elemAtDefault elemAt removeElems sublist split lsplit rsplit;
    inherit (lib.math) pow powi abs;
    inherit (lib.radix) intToHex;
    inherit (lib.shellscript)
      wrapShellScript writeShellScriptShebang writeNuScript;
    inherit (lib.trivial) imply implyDefault applyArgs;
    inherit (lib.units) bytes kbytes;
  };
in prev // prelude // {
  birdos = {
    inherit lib prelude;
    inherit (lib.builders)
      mkFlakeTree mkFlakeSystems mkJoinedOverlays mkUnfreeOverlay mkHost mkHome;
    inherit (lib) colors;
  };

  maintainers.spikespaz = {
    email = "jacob@birkett.dev";
    github = "spikespaz";
    githubId = "MDQ6VXNlcjEyNTAyOTg4";
    name = 12502988;
  };
}
