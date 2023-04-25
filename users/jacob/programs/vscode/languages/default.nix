args@{ lib, mkModuleIndex, ... }:
mkModuleIndex {
  path = ./.;
  # TODO doesn't work
  #   include = {
  #     all = lib.mkMerge (
  #       builtins.attrValues (mkModuleIndex {path = ./.;} args)
  #     );
  #   };
} args
