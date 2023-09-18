lib: lib0:
let
  inherit (import ./attrsets.nix { lib = lib0; }) importDir;
  libAttrs =
    lib.mapAttrs (_: fn: fn { inherit lib; }) (importDir ./. "default.nix");

  prelude = {
    inherit (libAttrs.attrsets)
      updates recursiveUpdates getAttrDefault getAttr thruAttr mapThruAttr
      mapListToAttrs attrPaths importDir;
    inherit (libAttrs.debug) traceM traceValM;
    # FIXME find a new name for `lib.lists.elemAt`, because `nixpkgs` uses
    # `with` on `lib` after `builtins` which makes it use this `elemAt`.
    inherit (libAttrs.lists)
      indicesOf indicesOfPred indexOfDefault indexOf lastIndexOfDefault
      lastIndexOf elemAtDefault removeElems sublist split lsplit rsplit lpad
      rpad flattenCond;
    inherit (libAttrs.math) pow powi mantissa round abs;
    inherit (libAttrs.sources)
      sourceFilter mkSourceFilter defaultSourceFilter unknownSourceFilter
      objectSourceFilter vcsSourceFilter editorSourceFilter flakeSourceFilter
      rustSourceFilter;
    # FIXME `substring` conflicts with `builtins.substring`.
    inherit (libAttrs.strings)
      indicesOfChar indexOfCharDefault indexOfChar lastIndexOfCharDefault
      lastIndexOfChar charAtDefault charAt removeChars lsplitString rsplitString
      lpadString rpadString strip lstrip rstrip trim startsWith endsWith
      toPercent;
    inherit (libAttrs.radix) intToHex;
    inherit (libAttrs.shellscript)
      wrapShellScript writeShellScriptShebang writeNuScript;
    inherit (libAttrs.trivial)
      not nand nor xor xnor imply implyDefault applyArgs applyAutoArgs;
    inherit (libAttrs.units) bytes kbytes;
    inherit (libAttrs.builders) mkDirEntry;
  };
in lib0 // prelude // {
  birdos = {
    inherit prelude;
    lib = libAttrs;
    inherit (libAttrs.builders)
      mkFlakeTree importDir mkFlakeSystems mkJoinedOverlays mkUnfreeOverlay
      mkHost mkHome;
    inherit (libAttrs.tests)
      evalTest runTestsRecursive mkTestSuite isTestSuite importTests
      collectTests;
    inherit (libAttrs) colors;
  };

  maintainers.spikespaz = {
    email = "jacob@birkett.dev";
    github = "spikespaz";
    githubId = "MDQ6VXNlcjEyNTAyOTg4";
    name = 12502988;
  };
}
