# This is a wrapper for `../scripts/json2nix.sh`.
{ pkgs, lib, nix, nixfmt-classic, ... }:
pkgs.patchShellScript ../scripts/json2nix.sh rec {
  name = "json2nix";
  destination = "/bin/${name}";
  runtimeInputs = [ nix nixfmt-classic ];
}
