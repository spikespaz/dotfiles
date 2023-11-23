# <https://ayats.org/blog/channels-to-flakes/>
{ lib, inputs, ... }:
lib.pipe inputs [
  (lib.filterAttrs (name: value: value._type == "flake"))
  (lib.mapAttrsToList (name: input: {
    environment.etc."nix/inputs/${name}".source = input.outPath;
    nix.nixPath = [ "${name}=/etc/nix/inputs/${name}" ];
    nix.registry.${name}.flake = input;
  }))
  lib.mkMerge
]
