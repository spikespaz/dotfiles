lib: lib0:
let
  callLibs = file: import file { inherit lib; };

  libAttrs = {
    attrsets = callLibs ./attrsets.nix;
    builders = callLibs ./builders.nix;
    debug = callLibs ./debug.nix;
    # generators = callLibs ./generators.nix;
    lists = callLibs ./lists.nix;
    math = callLibs ./math.nix;
    radix = callLibs ./radix.nix;
    sources = callLibs ./sources.nix;
    strings = callLibs ./strings.nix;
    tests = callLibs ./tests.nix;
    shellscript = callLibs ./shellscript.nix;
    trivial = callLibs ./trivial.nix;
    units = callLibs ./units.nix;
    colors = callLibs ./colors;
  };

  prelude = {
    inherit (libAttrs.attrsets)
      updates recursiveUpdates getAttrDefault getAttr thruAttr mapThruAttr
      mapListToAttrs attrPaths;
    inherit (libAttrs.debug) traceM traceValM;
    # FIXME find a new name for `lib.lists.elemAt`, because `nixpkgs` uses
    # `with` on `lib` after `builtins` which makes it use this `elemAt`.
    inherit (libAttrs.lists)
      indicesOf indicesOfPred indexOfDefault indexOf lastIndexOfDefault
      lastIndexOf elemAtDefault removeElems sublist split lsplit rsplit lpad
      rpad flattenCond;
    inherit (libAttrs.math) pow powi abs;
    inherit (libAttrs.sources)
      sourceFilter mkSourceFilter defaultSourceFilter unknownSourceFilter
      objectSourceFilter vcsSourceFilter editorSourceFilter flakeSourceFilter
      rustSourceFilter;
    # FIXME `substring` conflicts with `builtins.substring`.
    inherit (libAttrs.strings)
      indicesOfChar indexOfCharDefault indexOfChar lastIndexOfCharDefault
      lastIndexOfChar charAtDefault charAt removeChars lsplitString rsplitString
      lpadString rpadString strip lstrip rstrip trim startsWith endsWith;
    inherit (libAttrs.tests) mkTests mkTestSuite runTestsRecursive;
    inherit (libAttrs.radix) intToHex;
    inherit (libAttrs.shellscript)
      wrapShellScript writeShellScriptShebang writeNuScript;
    inherit (libAttrs.trivial)
      not nand nor xor xnor imply implyDefault applyArgs;
    inherit (libAttrs.units) bytes kbytes;
  };
in lib0 // prelude // {
  birdos = {
    inherit prelude;
    lib = libAttrs;
    inherit (libAttrs.builders)
      mkFlakeTree mkFlakeSystems mkJoinedOverlays mkUnfreeOverlay mkHost mkHome;
    inherit (libAttrs) colors;
  };

  maintainers.spikespaz = {
    email = "jacob@birkett.dev";
    github = "spikespaz";
    githubId = "MDQ6VXNlcjEyNTAyOTg4";
    name = 12502988;
  };
}
