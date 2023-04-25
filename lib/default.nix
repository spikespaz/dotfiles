{ lib }:
lib.makeExtensible (self:
  let callLibs = file: import file { lib = self; };
  in {
    attrsets = callLibs ./attrsets.nix;
    debug = callLibs ./debug.nix;
    flake-utils = callLibs ./flake-utils.nix;
    generators = callLibs ./generators.nix;
    lists = callLibs ./lists.nix;
    trivial = callLibs ./trivial.nix;

    inherit (self.attrsets) updates deepMergeAttrs;
    inherit (self.debug) traceM traceValM;
    inherit (self.lists) indicesOf getElemAt split lsplit rsplit;
    inherit (self.trivial) imply implyDefault;
  })
