args @ {mkModuleIndex, ...}:
mkModuleIndex {
  path = ./.;
  ignore = ["flake.nix"];
} args
