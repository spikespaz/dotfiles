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
    strings = callLibs ./strings.nix;
    tests = callLibs ./tests.nix;
    shellscript = callLibs ./shellscript.nix;
    trivial = callLibs ./trivial.nix;
    units = callLibs ./units.nix;
    colors = callLibs ./colors;
  };

  prelude = {
    inherit (lib.attrsets)
      updates recursiveUpdates getAttrDefault getAttr thruAttr mapThruAttr
      mapListToAttrs attrPaths;
    inherit (lib.debug) traceM traceValM;
    # FIXME find a new name for `lib.lists.elemAt`, because `nixpkgs` uses
    # `with` on `lib` after `builtins` which makes it use this `elemAt`.
    inherit (lib.lists)
      indicesOf indicesOfPred indexOfDefault indexOf lastIndexOfDefault
      lastIndexOf elemAtDefault removeElems sublist split lsplit rsplit lpad
      rpad flattenCond;
    inherit (lib.math) pow powi abs;
    # FIXME `substring` conflicts with `builtins.substring`.
    inherit (lib.strings)
      indicesOfChar indexOfCharDefault indexOfChar lastIndexOfCharDefault
      lastIndexOfChar charAtDefault charAt removeChars lsplitString rsplitString
      lpadString rpadString strip lstrip rstrip startsWith endsWith;
    inherit (lib.tests) mkTests mkTestSuite runTestsRecursive;
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
