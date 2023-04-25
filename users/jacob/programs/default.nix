args@{ mkModuleIndex, ... }:
mkModuleIndex {
  path = ./.;
  ignore = [ "toplevel.nix" ];
  include = import ./toplevel.nix args;
} args
